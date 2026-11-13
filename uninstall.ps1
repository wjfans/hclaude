# hclaude uninstaller
#
#   irm https://raw.githubusercontent.com/wjfans/hclaude/main/uninstall.ps1 | iex
#
# Removes hclaude.cmd, hclaude-run.ps1 and the File Explorer context menu item.
# %USERPROFILE%\.local\bin stays on your PATH: other tools (such as Claude
# Code's own installer) use that folder too.
# Works in Windows PowerShell 5.1 and PowerShell 7. Keep this file ASCII-only.

$ErrorActionPreference = 'Stop'
$dir = Join-Path $env:USERPROFILE '.local\bin'

foreach ($f in 'hclaude.cmd', 'hclaude-run.ps1') {
    $p = Join-Path $dir $f
    if (Test-Path -LiteralPath $p) {
        Remove-Item -LiteralPath $p -Force
        Write-Host "  removed $p"
    }
}

foreach ($root in 'Directory\Background\shell', 'Directory\shell') {
    $path = "Software\Classes\$root\hclaude"
    $k = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey($path)
    if ($k) {
        $k.Close()
        [Microsoft.Win32.Registry]::CurrentUser.DeleteSubKeyTree($path)
        Write-Host "  removed context menu HKCU\$path"
    }
}

Write-Host ''
Write-Host 'hclaude is uninstalled.' -ForegroundColor Green
