# hclaude

[English](README.md) | **繁體中文**

**給 [Herdr](https://herdr.dev) 使用者的 Windows 小工具：在檔案總管裡，一個步驟就把 [Claude Code](https://claude.com/claude-code) 開在 Herdr 裡。**

## 為什麼需要這個工具

### Herdr 是什麼

[Herdr](https://herdr.dev) 是一個用來管理終端機和 AI coding agent 的桌面 app。如果你同時讓好幾個 Claude Code 在不同專案裡工作，Herdr 可以幫你：

- **依專案分類**：每個專案是一個 space，裡面可以有多個 tab 和終端機。
- **一眼看出每個 Claude 的狀態**：左側的 agents 清單會即時顯示每個 Claude 是工作中、已完成，還是在等你回覆或核准權限。
- **需要你處理時主動通知**：Claude 卡住等你，或在你沒注意時做完了，Herdr 會發出提示音和通知。點一下就跳到那個 Claude。

[Claude Code](https://claude.com/claude-code) 則是 Anthropic 推出、在終端機裡執行的 AI 程式開發助手，指令是 `claude`。

### 目前的作法有什麼問題

很多人在 Windows 上習慣這樣開 Claude Code：

> 在檔案總管進到專案資料夾 → 在上方路徑列輸入 `claude` → 按 Enter

這樣很快，但 **Claude 會開在一般的主控台視窗裡，不在 Herdr 裡**。Herdr 只會顯示由它自己開啟的終端機，所以：

- Herdr 的 agents 清單看不到這個 Claude，也不會在它需要你時通知你。
- 已經在跑的 Claude 沒辦法事後搬進 Herdr，只能關掉重開。

要讓 Claude 開在 Herdr 裡，原本必須：

1. 開啟 Herdr
2. 回到檔案總管，複製專案資料夾的路徑
3. 在 Herdr 的終端機輸入 `cd <路徑>`
4. 再輸入 `claude`

每換一個專案就要重複一次，比原本的作法麻煩很多。

### hclaude 怎麼解決

**hclaude 把上面這四個步驟合成一步。** 你的習慣幾乎不用改，只要：

- 在檔案總管路徑列輸入 **`hclaude`**，取代原本的 `claude`；或是
- 在資料夾上按右鍵，選「**在 Herdr 開啟 Claude**」

Claude Code 就會以這個資料夾開在 Herdr 裡。如果 Herdr 已經有這個專案的 space，會直接在裡面加一個 tab，不會重複建立。

| | 原本在路徑列打 `claude` | 用 hclaude |
|---|---|---|
| 怎麼開 | 路徑列打 `claude` | 路徑列打 `hclaude`，或按右鍵 |
| Claude 開在哪裡 | 獨立的主控台視窗 | Herdr 裡，依專案分好 space |
| 看得到狀態嗎 | 要自己切過去看 | Herdr 的 agents 清單即時顯示 |
| 需要你時會通知嗎 | 不會 | 會，有提示音和通知 |

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
