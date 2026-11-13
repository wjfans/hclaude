@echo off
rem hclaude: open Claude Code in Herdr, in the current folder.
rem Usage: hclaude [claude args, e.g. --continue]   (logic: hclaude-run.ps1)
rem Needs: Herdr, PowerShell 7 (pwsh), claude.
where pwsh >nul 2>nul || (
  echo hclaude needs PowerShell 7. Install it with:  winget install Microsoft.PowerShell
  pause
  exit /b 1
)
rem "start" gives pwsh its own console, so hiding it never hides the caller's window.
start "" /min pwsh -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "%~dp0hclaude-run.ps1" %*
