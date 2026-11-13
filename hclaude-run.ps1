# hclaude：在 Herdr 裡、以目前資料夾開 Claude Code。由 hclaude.cmd 呼叫。
# 用法（檔案總管路徑列或任何終端機）：hclaude [claude 的參數，例如 --continue]
# 這個資料夾已有 space 就加一個 tab，沒有就開新的 space。
# 需要：Herdr、PowerShell 7（pwsh）、claude 指令。
# 注意：此檔必須存成 UTF-8 with BOM，Windows PowerShell 5.1 才不會把中文讀成亂碼。

# 被 Windows PowerShell 5.1 直接執行時，交給 PowerShell 7：
# 5.1 傳 JSON 給外部程式會吃掉引號，而且它的 cd 不會改到行程的工作目錄。
if ($PSVersionTable.PSEdition -ne 'Core') {
    $pwsh = Get-Command pwsh -ErrorAction SilentlyContinue
    if (-not $pwsh) { Write-Error 'hclaude 需要 PowerShell 7：winget install Microsoft.PowerShell'; exit 1 }
    $wd = (Get-Location).ProviderPath
    if ($wd.EndsWith('\')) { $wd += '.' }
    & $pwsh.Source -NoProfile -ExecutionPolicy Bypass -WorkingDirectory $wd -File $PSCommandPath @args
    exit $LASTEXITCODE
}

$ErrorActionPreference = 'Stop'
# herdr-app 輸出 UTF-8；主控台是 Big5 時中文路徑會解錯碼，導致比對不到既有的 space。
try { [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false) } catch {}

function Fail([string]$msg) {
    Add-Type -AssemblyName PresentationFramework
    [void][System.Windows.MessageBox]::Show($msg, 'hclaude', 'OK', 'Error')
    exit 1
}

# 找 Herdr：先找 PATH，再找預設的個人安裝位置。
$exe = (Get-Command herdr-app.exe -ErrorAction SilentlyContinue).Source
if (-not $exe) { $exe = Join-Path $env:LOCALAPPDATA 'Programs\herdr-app\herdr-app.exe' }
if (-not (Test-Path -LiteralPath $exe)) { Fail '找不到 Herdr（herdr-app.exe），請先安裝 Herdr。' }

if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
    Fail '找不到 claude 指令，請先安裝 Claude Code。'
}

# herdr-app.exe 是 GUI 程式：PowerShell 要把輸出接到 pipe 才會等它跑完、拿到輸出。
function Herdr {
    $o = & $exe @args 2>&1 | Out-String
    [pscustomobject]@{ ok = ($LASTEXITCODE -eq 0); out = $o }
}

function Norm([string]$p) {
    if (-not $p) { return '' }
    $p.TrimEnd('\').ToLowerInvariant()
}

$folder = (Get-Location).ProviderPath
if (-not (Test-Path -LiteralPath $folder -PathType Container)) { Fail "不是資料夾：$folder" }

# 開啟 Herdr（已開啟時會把視窗叫到前面），等它能回應。
Start-Process -FilePath $exe
$ls = $null
for ($i = 0; $i -lt 60; $i++) {
    $r = Herdr ls
    if ($r.ok) { $ls = $r.out | ConvertFrom-Json; break }
    Start-Sleep -Milliseconds 500
}
if (-not $ls) { Fail 'Herdr 沒有在 30 秒內回應。' }

$argv = @('claude') + @($args)
$space = $ls.spaces |
    Where-Object { -not $_.machine -and (Norm $_.folder) -eq (Norm $folder) } |
    Select-Object -First 1

if ($space) {
    $json = @{ space = $space.id; folder = $folder; argv = $argv } | ConvertTo-Json -Compress
    $r = Herdr do tab.new $json
    if (-not $r.ok) { Fail "tab.new 失敗：$($r.out)" }
    $sel = @{ id = $space.id } | ConvertTo-Json -Compress
    [void](Herdr do space.select $sel)
} else {
    $json = @{ folder = $folder; argv = $argv; machine = '' } | ConvertTo-Json -Compress
    $r = Herdr do space.new $json
    if (-not $r.ok) { Fail "space.new 失敗：$($r.out)" }
}
