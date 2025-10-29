# raycast_conf

Raycast用のカスタムスクリプトと拡張機能のコレクション

## 📁 プロジェクト構成

```
raycast_conf/
├── scripts/              # スクリプトコマンド(.sh)
├── extensions/           # Raycast拡張機能(Node.js/TypeScript)
│   └── okan-tasks/      # おかんタスク確認拡張
├── .env                  # 環境変数(Git管理外)
├── .env.example         # 環境変数のテンプレート
└── README.md
```

## 🚀 スクリプトコマンド

Raycastで使用可能なシェルスクリプトコマンドです。

### 含まれるスクリプト

- 🌐 **open_metalife.sh** - MetaLifeのスペースを開く
- 𝕏 **open_x.sh** - X(旧Twitter)を開く
- 📅 **open_calendar.sh** - Googleカレンダーを開く
- 📧 **open_mail.sh** - Gmailを開く
- 🐙 **open_github.sh** - GitHubを開く
- 📹 **activate_meet.sh** - Google Meetタブをアクティブ化
- ☕ **prevent_sleep.sh** - スリープ防止
- ⏰ **prevent_sleep_timer.sh** - タイマー付きスリープ防止

詳細は [scripts/README.md](scripts/README.md) を参照してください。

---

## 🔧 拡張機能

### 📊 Okan Tasks (extensions/okan-tasks)

おかんスプレッドシートの未完了タスクをRaycast上で確認できる拡張機能

**使用方法**: `Raycast → "Check Okan Tasks"`

**機能**:
- Google Sheets APIを使用してリアルタイムにタスクを取得
- あなたの未完了タスクのみを表示
- タスクを選択すると該当行のスプレッドシートが開く
- キーボードショートカット対応
  - `Enter`: スプレッドシートで開く
  - `⌘ + C`: タスク名をコピー
  - `⌘ + Shift + C`: URLをコピー

**セットアップ**:
詳細は [extensions/okan-tasks/README.md](extensions/okan-tasks/README.md) を参照

---

## 📝 セットアップ

### 1. リポジトリのクローン
```bash
git clone https://github.com/nokki-y/raycast_conf.git
cd raycast_conf
```

### 2. 環境変数の設定
```bash
cp .env.example .env
# .env ファイルを編集して実際の値を設定
```

### 3. Raycastの設定

#### スクリプトコマンド
1. Raycast Preferences → Extensions → Script Commands
2. 「Add Directories」をクリック
3. `raycast_conf/scripts` ディレクトリを選択

#### 拡張機能
各拡張機能のREADMEを参照してください。

---

## 🌍 環境変数

`.env`ファイルで以下の環境変数を設定できます:

```bash
# MetaLife
METALIFE_SPACE_ID=your_space_id_here

# Google アカウント
GOOGLE_ACCOUNT_INDEX=0

# おかんスプレッドシート
OKAN_SPREADSHEET_ID=your_spreadsheet_id_here
OKAN_SHEET_GID=your_sheet_gid_here
OKAN_SHEET_NAME=your_sheet_name_here
OKAN_MY_NAME=your_name_here
```

詳細は [.env.example](.env.example) を参照してください。

---

## 💻 必要な環境

- macOS
- Raycast
- Bash
- Google Chrome (ブラウザ操作系スクリプト使用時)
- Node.js v16以上 (拡張機能使用時)

---

## 📄 ライセンス

MIT

## 👤 作成者

nokki-y ([@nokki-y](https://github.com/nokki-y))
