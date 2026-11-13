# hclaude installer
#
#   irm https://raw.githubusercontent.com/wjfans/hclaude/main/install.ps1 | iex
#
# Copies hclaude.cmd and hclaude-run.ps1 to %USERPROFILE%\.local\bin and adds
# that folder to your user PATH if it is not there yet. Run it from a clone to
# install the local files instead of downloading them.
# Works in Windows PowerShell 5.1 and PowerShell 7. Keep this file ASCII-only.

$ErrorActionPreference = 'Stop'
$repo  = 'https://raw.githubusercontent.com/wjfans/hclaude/main'
$files = @('hclaude.cmd', 'hclaude-run.ps1')
$dir   = Join-Path $env:USERPROFILE '.local\bin'

# Windows PowerShell 5.1 may not enable TLS 1.2 by default.
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

New-Item -ItemType Directory -Force -Path $dir | Out-Null
$local = $PSScriptRoot  # empty when piped into iex
foreach ($f in $files) {
    $dest = Join-Path $dir $f
    $src  = if ($local) { Join-Path $local $f }
    if ($src -and (Test-Path -LiteralPath $src)) {
        Copy-Item -LiteralPath $src -Destination $dest -Force
    } else {
        # -OutFile keeps the bytes as they are (hclaude-run.ps1 needs its UTF-8 BOM).
        Invoke-WebRequest -UseBasicParsing -Uri "$repo/$f" -OutFile $dest
    }
    Unblock-File -LiteralPath $dest -ErrorAction SilentlyContinue
    Write-Host "  installed $dest"
}

# Add the folder to the user PATH, keeping the value's type (REG_EXPAND_SZ)
# and any %VARIABLES% in it as they are.
function Same([string]$a, [string]$b) {
    [Environment]::ExpandEnvironmentVariables($a).TrimEnd('\') -ieq $b.TrimEnd('\')
}
$machinePath = [Environment]::GetEnvironmentVariable('Path', 'Machine')
$key = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey('Environment', $true)
$userPath = [string]$key.GetValue('Path', '', 'DoNotExpandEnvironmentNames')
$present = @(($userPath + ';' + $machinePath) -split ';' | Where-Object { $_ -and (Same $_ $dir) }).Count -gt 0
if (-not $present) {
    $new = (@($userPath.TrimEnd(';')) + $dir | Where-Object { $_ }) -join ';'
    $key.SetValue('Path', $new, [Microsoft.Win32.RegistryValueKind]::ExpandString)
    # Tell Explorer and other programs that the environment changed.
    Add-Type -Namespace HClaude -Name Native -MemberDefinition @'
[DllImport("user32.dll", CharSet = CharSet.Unicode)]
public static extern IntPtr SendMessageTimeout(IntPtr hWnd, uint msg, UIntPtr wParam, string lParam, uint flags, uint timeout, out UIntPtr result);
'@
    $r = [UIntPtr]::Zero
    [void][HClaude.Native]::SendMessageTimeout([IntPtr]0xffff, 0x1A, [UIntPtr]::Zero, 'Environment', 2, 5000, [ref]$r)
    Write-Host "  added $dir to your user PATH"
}
$key.Close()
if (-not (@($env:Path -split ';' | Where-Object { $_ -and (Same $_ $dir) }).Count)) { $env:Path += ";$dir" }

# Check what hclaude needs at run time.
$missing = @()
if (-not (Get-Command pwsh -ErrorAction SilentlyContinue)) { $missing += 'PowerShell 7     -> winget install Microsoft.PowerShell' }
$herdr = Get-Command herdr-app.exe -ErrorAction SilentlyContinue
if (-not $herdr -and -not (Test-Path (Join-Path $env:LOCALAPPDATA 'Programs\herdr-app\herdr-app.exe'))) { $missing += 'Herdr            -> https://herdr.dev' }
if (-not (Get-Command claude -ErrorAction SilentlyContinue)) { $missing += 'Claude Code      -> https://claude.com/claude-code' }

Write-Host ''
if ($missing.Count) {
    Write-Host 'hclaude is installed, but it still needs:' -ForegroundColor Yellow
    $missing | ForEach-Object { Write-Host "  $_" -ForegroundColor Yellow }
} else {
    Write-Host 'hclaude is ready. In File Explorer, open a project folder, type hclaude in the address bar and press Enter.' -ForegroundColor Green
}
if (-not $present) { Write-Host 'If File Explorer does not find hclaude yet, sign out and back in once.' }
