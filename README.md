# hclaude

**English** | [繁體中文](README.zh-TW.md)

Open [Claude Code](https://claude.com/claude-code) inside [Herdr](https://herdr.dev) from any folder on Windows: type `hclaude` in File Explorer's address bar and press Enter.

Without it, a Claude Code session started from File Explorer runs in a plain console window, outside Herdr. Herdr can only manage terminals it started, so that session never shows up in Herdr's spaces or agents list. To get it into Herdr you'd have to open Herdr, copy the folder path, `cd` into it, and then run `claude`. `hclaude` does all of that in one step.

## What it does

When you run `hclaude` in a folder, it:

1. Starts Herdr, or brings its window to the front if it's already running.
2. Starts Claude Code in that folder, inside Herdr:
   - If a Herdr space already points at the folder, Claude opens as a new tab in that space and the space is selected.
   - Otherwise, a new space is created for the folder.
3. Passes any arguments through to `claude`.

| You type | Result |
|---|---|
| `hclaude` | Claude Code in this folder, in Herdr |
| `hclaude --continue` | Continue the most recent conversation in this folder |
| `hclaude --resume` | Pick a past conversation to resume |

It works from File Explorer's address bar, `cmd`, Windows PowerShell 5.1 and PowerShell 7.

## Requirements

- Windows 10 or 11
- [Herdr](https://herdr.dev), the desktop app (installed per user, or `herdr-app.exe` on your `PATH`)
- [PowerShell 7](https://learn.microsoft.com/powershell/scripting/install/installing-powershell-on-windows) (`pwsh`): `winget install Microsoft.PowerShell`
- [Claude Code](https://claude.com/claude-code), with `claude` on your `PATH`

## Install

Run this in PowerShell:

```powershell
irm https://raw.githubusercontent.com/wjfans/hclaude/main/install.ps1 | iex
```

The installer:

- copies `hclaude.cmd` and `hclaude-run.ps1` to `%USERPROFILE%\.local\bin`
- adds that folder to your user `PATH` if it isn't there yet
- tells you if PowerShell 7, Herdr or Claude Code is missing

If File Explorer doesn't find `hclaude` right after you install it, sign out and back in once.

### Manual install

1. Download [`hclaude.cmd`](hclaude.cmd) and [`hclaude-run.ps1`](hclaude-run.ps1). Use the download button on each file's page; don't copy and paste the text.
2. Put both files in the same folder on your `PATH`.
3. If you downloaded them in a browser, unblock them: `Get-ChildItem <folder>\hclaude* | Unblock-File`.

Keep `hclaude-run.ps1` saved as **UTF-8 with BOM**. Without the BOM, Windows PowerShell 5.1 can't read its non-ASCII comments and messages. If you edit the file, make sure your editor keeps the BOM.

## How it works

- `hclaude.cmd` is the command you type. It launches `hclaude-run.ps1` with `pwsh -ExecutionPolicy Bypass` in a hidden window of its own. That way your PowerShell execution policy doesn't matter, and the window you typed in stays as it is.
- `hclaude-run.ps1` uses the `herdr-app` CLI:
  - `herdr-app ls` finds an existing space for the folder.
  - `herdr-app do space.new` or `herdr-app do tab.new` starts `claude` there.
- The logic script is deliberately not named `hclaude.ps1`. PowerShell runs a `.ps1` before a `.cmd` with the same name, so that name would put the script under your execution policy again.

## Troubleshooting

| Symptom | Fix |
|---|---|
| `'hclaude' is not recognized` | The install folder isn't on `PATH` in that window yet. Open a new window, or sign out and back in. |
| `hclaude needs PowerShell 7` | `winget install Microsoft.PowerShell` |
| Error dialog: can't find Herdr / `claude` | Install the missing program, or put it on your `PATH`. |
| Error dialog: Herdr did not respond within 30 seconds | Start Herdr once by hand and check that it opens. |
| A new space every time, instead of a new tab | A space matches only while its first terminal is still in that folder. If you `cd` somewhere else in it, `hclaude` creates a new space. |

## Uninstall

```powershell
Remove-Item "$env:USERPROFILE\.local\bin\hclaude.cmd", "$env:USERPROFILE\.local\bin\hclaude-run.ps1"
```

The installer may also have added `%USERPROFILE%\.local\bin` to your user `PATH`. Other tools, such as Claude Code's own installer, use that folder too, so check before you remove it from `PATH`.

## License

[MIT](LICENSE)

This is an unofficial community tool. It is not affiliated with Anthropic or with Herdr.
