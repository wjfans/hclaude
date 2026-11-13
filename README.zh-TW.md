# hclaude

[English](README.md) | **繁體中文**

在 Windows 上，從任何資料夾直接開 [Claude Code](https://claude.com/claude-code)，而且開在 [Herdr](https://herdr.dev) 裡：在檔案總管的路徑列打 `hclaude`，或在資料夾上按右鍵。

在檔案總管路徑列打 `claude`，Claude 會開在一般的主控台視窗裡。Herdr 只能管理它自己開的終端機，所以這種 Claude 不會出現在 Herdr 的 spaces 或 agents 清單裡。想在 Herdr 裡開，原本要先開 Herdr、複製資料夾路徑、`cd` 過去，再打 `claude`。`hclaude` 把這些步驟合成一步。

## 功能

在某個資料夾執行 `hclaude` 時，它會：

1. 開啟 Herdr；如果 Herdr 已經開著，就把視窗叫到前面。
2. 在 Herdr 裡、以這個資料夾開 Claude Code：
   - 如果已經有 space 對應到這個資料夾，就在那個 space 加一個 tab，並切換過去。
   - 如果還沒有，就為這個資料夾建立新的 space。
3. 把你給的參數原樣傳給 `claude`。

| 你打的 | 結果 |
|---|---|
| `hclaude` | 在 Herdr 裡，以這個資料夾開 Claude Code |
| `hclaude --continue` | 接上這個資料夾最近一次的對話 |
| `hclaude --resume` | 從清單挑選要接續的對話 |

檔案總管路徑列、`cmd`、Windows PowerShell 5.1 和 PowerShell 7 都可以使用。

### 右鍵選單

在資料夾上按右鍵，或在資料夾內的空白處按右鍵，選 **在 Herdr 開啟 Claude**。效果跟在那裡打 `hclaude` 一樣。

- **Windows 11**：這個項目在「**顯示更多選項**」裡面，也可以按 **Shift + 右鍵** 直接打開。Windows 11 不讓應用程式透過登錄檔把項目加到新版選單的第一層。
- 選單名稱會依 Windows 顯示語言而定：繁體中文顯示「在 Herdr 開啟 Claude」，簡體中文顯示「在 Herdr 中打开 Claude」，其他語言顯示「Open Claude in Herdr」。

## 需求

- Windows 10 或 11
- [Herdr](https://herdr.dev) 桌面 app（預設的個人安裝，或 `herdr-app.exe` 在 `PATH` 裡）
- [PowerShell 7](https://learn.microsoft.com/powershell/scripting/install/installing-powershell-on-windows)（`pwsh`）：`winget install Microsoft.PowerShell`
- [Claude Code](https://claude.com/claude-code)，而且 `claude` 指令在 `PATH` 裡

## 安裝

在 PowerShell 執行：

```powershell
irm https://raw.githubusercontent.com/wjfans/hclaude/main/install.ps1 | iex
```

安裝程式會：

- 把 `hclaude.cmd` 和 `hclaude-run.ps1` 複製到 `%USERPROFILE%\.local\bin`
- 如果這個資料夾還不在使用者 `PATH` 裡，就把它加進去
- 加入檔案總管的右鍵選單項目（只套用在目前使用者，不需要系統管理員權限）
- 檢查 PowerShell 7、Herdr、Claude Code 有沒有裝，缺少的會提醒你

裝好後，如果在檔案總管打 `hclaude` 沒有反應，請登出再登入一次。要更新到新版本時，再執行一次同樣的指令就好。

### 手動安裝

1. 下載 [`hclaude.cmd`](hclaude.cmd) 和 [`hclaude-run.ps1`](hclaude-run.ps1)。請用各檔案頁面上的下載按鈕，不要用複製貼上。
2. 把兩個檔案放在同一個資料夾，而且這個資料夾要在 `PATH` 裡。
3. 如果是用瀏覽器下載的，請解除封鎖：`Get-ChildItem <資料夾>\hclaude* | Unblock-File`。

手動安裝不會加入右鍵選單。需要右鍵選單的話，請改用上面的安裝程式。

`hclaude-run.ps1` 必須保持 **UTF-8 with BOM** 編碼，否則 Windows PowerShell 5.1 會把裡面的中文讀成亂碼。自己修改這個檔案時，請確認編輯器存檔後 BOM 還在。

## 運作方式

- `hclaude.cmd` 是你實際輸入的指令。它用 `pwsh -ExecutionPolicy Bypass` 另開一個隱藏的視窗，執行 `hclaude-run.ps1`。所以不受 PowerShell 執行原則影響，也不會動到你打指令的那個視窗。
- `hclaude-run.ps1` 透過 `herdr-app` 的命令列工具操作 Herdr：
  - 用 `herdr-app ls` 找出是否已經有這個資料夾的 space。
  - 用 `herdr-app do space.new` 或 `herdr-app do tab.new` 在那裡開 `claude`。
- 右鍵選單是寫在目前使用者登錄檔裡的 shell 動詞：`HKCU\Software\Classes\Directory\shell\hclaude`，以及資料夾內空白處用的 `...\Directory\Background\shell\hclaude`。它執行的是 `cmd.exe /d /c cd /d "%V" && "<安裝資料夾>\hclaude.cmd"`。
- 邏輯檔刻意不叫 `hclaude.ps1`。PowerShell 遇到同名的 `.ps1` 和 `.cmd` 時會先執行 `.ps1`，取這個名字的話又會受到執行原則限制。

## 疑難排解

| 狀況 | 解法 |
|---|---|
| 「無法辨識 'hclaude'」 | 這個視窗的 `PATH` 還沒包含安裝資料夾。開一個新視窗，或登出再登入。 |
| 出現 `hclaude needs PowerShell 7` | 執行 `winget install Microsoft.PowerShell` |
| 跳出「找不到 Herdr」或「找不到 claude 指令」 | 安裝缺少的程式，或把它加進 `PATH`。 |
| 跳出「Herdr 沒有在 30 秒內回應」 | 先手動開一次 Herdr，確認它能正常啟動。 |
| 每次都開新的 space，而不是加 tab | space 的資料夾是看它第一個終端機目前所在的位置。如果你在那個終端機 `cd` 到別處，就比對不到原本的資料夾，`hclaude` 會另開新的 space。 |

## 移除

```powershell
irm https://raw.githubusercontent.com/wjfans/hclaude/main/uninstall.ps1 | iex
```

這會刪除兩個腳本和右鍵選單項目。`%USERPROFILE%\.local\bin` 會留在 `PATH` 裡，因為其他工具（例如 Claude Code 自己的安裝程式）也會使用這個資料夾。

## 授權

[MIT](LICENSE)

這是非官方的社群工具，與 Anthropic 和 Herdr 沒有任何關係。
