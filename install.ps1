# hclaude installer
#
#   irm https://raw.githubusercontent.com/wjfans/hclaude/main/install.ps1 | iex
#
# Copies hclaude.cmd and hclaude-run.ps1 to %USERPROFILE%\.local\bin, adds
# that folder to your user PATH if it is not there yet, and adds a File
# Explorer context menu item. Run it from a clone to install the local files
# instead of downloading them. Running it again updates everything in place.
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

$herdr = (Get-Command herdr-app.exe -ErrorAction SilentlyContinue).Source
if (-not $herdr) {
    $p = Join-Path $env:LOCALAPPDATA 'Programs\herdr-app\herdr-app.exe'
    if (Test-Path -LiteralPath $p) { $herdr = $p }
}
$claude = Get-Command claude -ErrorAction SilentlyContinue

# File Explorer context menu: right-click a folder, or empty space inside one.
# On Windows 11 it is under "Show more options" (or Shift+right-click).
# The label follows the Windows display language (Get-UICulture can report the
# install language instead). Chinese is built from char codes: this file must stay ASCII.
Add-Type -Namespace HClaude -Name Lang -MemberDefinition '[DllImport("kernel32.dll")] public static extern ushort GetUserDefaultUILanguage();'
$ui = ([Globalization.CultureInfo][int][HClaude.Lang]::GetUserDefaultUILanguage()).Name
$label = if ($ui -match '^zh-(TW|HK|MO|Hant)') { "$([char]0x5728) Herdr $([char]0x958B)$([char]0x555F) Claude" }
         elseif ($ui -like 'zh*') { "$([char]0x5728) Herdr $([char]0x4E2D)$([char]0x6253)$([char]0x5F00) Claude" }
         else { 'Open Claude in Herdr' }
$icon = if ($claude -and $claude.Source -like '*.exe') { "`"$($claude.Source)`",0" }
        elseif ($herdr) { "`"$herdr`",0" }
        else { 'cmd.exe' }
$command = "cmd.exe /d /c cd /d `"%V`" && `"$(Join-Path $dir 'hclaude.cmd')`""
foreach ($root in 'Directory\Background\shell', 'Directory\shell') {
    $verb = [Microsoft.Win32.Registry]::CurrentUser.CreateSubKey("Software\Classes\$root\hclaude")
    $verb.SetValue('', $label)
    $verb.SetValue('Icon', $icon)
    $cmd = $verb.CreateSubKey('command')
    $cmd.SetValue('', $command)
    $cmd.Close(); $verb.Close()
}
Write-Host "  added File Explorer context menu: $label"

# Check what hclaude needs at run time.
$missing = @()
if (-not (Get-Command pwsh -ErrorAction SilentlyContinue)) { $missing += 'PowerShell 7     -> winget install Microsoft.PowerShell' }
if (-not $herdr) { $missing += 'Herdr            -> https://herdr.dev' }
if (-not $claude) { $missing += 'Claude Code      -> https://claude.com/claude-code' }

Write-Host ''
if ($missing.Count) {
    Write-Host 'hclaude is installed, but it still needs:' -ForegroundColor Yellow
    $missing | ForEach-Object { Write-Host "  $_" -ForegroundColor Yellow }
} else {
    Write-Host 'hclaude is ready. In File Explorer, open a project folder and type hclaude in the address bar,' -ForegroundColor Green
    Write-Host 'or right-click the folder (Windows 11: Show more options).' -ForegroundColor Green
}
if (-not $present) { Write-Host 'If File Explorer does not find hclaude yet, sign out and back in once.' }
