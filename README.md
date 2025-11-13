# raycast_conf

Raycast用のカスタムスクリプトと拡張機能のコレクション

## 📁 プロジェクト構成

```
raycast_conf/
├── commands/             # スクリプトコマンド(.sh)ソースファイル
│   ├── .env             # スクリプト用環境変数(Git管理外)
│   ├── .env.example     # 環境変数テンプレート
│   └── release/         # ビルド済みコマンド(Git管理外)
├── scripts/              # ビルドスクリプト
│   └── build-commands.sh # コマンドビルドスクリプト
├── extensions/           # Raycast拡張機能(Node.js/TypeScript)
│   └── okan-tasks/      # おかんタスク確認拡張
├── package.json         # セキュリティチェック用npm scripts
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

**注意**: スクリプトはビルドが必要です。環境変数を設定後、`./scripts/build-commands.sh`を実行して`commands/release/`にビルドしてください。

---

## 🔧 拡張機能

### 📊 Okan Tasks (extensions/okan-tasks)

おかんスプレッドシートの未完了タスクをRaycast上で確認できる拡張機能

**使用方法**: `Raycast → "Check Okan Tasks"`

**機能**:
- ✅ **期限フィルタリング**: 期限切れ + 2営業日以内のタスクのみ表示
- ✅ **ステータス自動判定**: 「完了」「対象外」を自動除外
- ✅ **直接編集**: タスクをクリックして該当セルで直接スプレッドシートを開く
- ✅ **自動トークン更新**: アクセストークンは自動的にリフレッシュ（手動更新不要）
- キーボードショートカット対応
  - `Enter`: スプレッドシートで開く
  - `⌘ + C`: タスク名をコピー
  - `⌘ + Shift + C`: URLをコピー

**セットアップ**:
- 開発者向け: [extensions/okan-tasks/README.md](extensions/okan-tasks/README.md)
- 配布先向け: [extensions/okan-tasks/SETUP_GUIDE.md](extensions/okan-tasks/SETUP_GUIDE.md)

---

## 📝 セットアップ

### 1. リポジトリのクローン
```bash
git clone https://github.com/nokki-y/raycast_conf.git
cd raycast_conf
```

### 2. 環境変数の設定（スクリプトコマンド用）
```bash
# commands/ ディレクトリに .env を作成
cp commands/.env.example commands/.env
# commands/.env ファイルを編集して実際の値を設定
```

**注意**: `.env`ファイルは**スクリプトコマンド専用**です。拡張機能の設定はRaycast Preferencesで行います。

### 3. スクリプトコマンドのビルド

すべてのスクリプトコマンドを`commands/release/`にビルドします。

```bash
./scripts/build-commands.sh
```

このスクリプトは以下を行います：
- すべての`.sh`ファイルを`commands/release/`にコピー
- 環境変数のプレースホルダー（`__DROPDOWN_DATA__`など）がある場合は、`commands/.env`の値で置換
- プレースホルダーがないファイルはそのままコピー

**環境変数を変更した場合は、再度ビルドを実行してください。**

### 4. セキュリティチェックのセットアップ (オプション)
```bash
npm install
```

詳細は [SETUP_SECURITY.md](SETUP_SECURITY.md) を参照してください。

### 5. Raycastの設定

#### スクリプトコマンド
1. Raycast Preferences → Extensions → Script Commands
2. 「Add Directories」をクリック
3. `raycast_conf/commands/release` ディレクトリを選択

#### 拡張機能
各拡張機能のREADMEを参照してください。

---

## ⚙️ 環境変数と設定

### スクリプトコマンドの設定

スクリプトコマンド（`.sh`ファイル）は、`commands/.env`ファイルで設定します。

**設定項目**:
- `METALIFE_SPACE_ID`: MetaLifeのスペースID
- `GOOGLE_ACCOUNT_INDEX`: Googleアカウントのインデックス（デフォルト: 0）
- `GITHUB_REPOSITORIES`: GitHubリポジトリ（カンマ区切りで複数指定可能、例: `user1/repo1,user2/repo2`）

詳細は [commands/.env.example](commands/.env.example) を参照してください。

**環境変数を変更した場合は、`./scripts/build-commands.sh`を再実行してください。**

### 拡張機能の設定

各Raycast拡張機能の設定は、**Raycast Preferences**で管理されます（`.env`は使用しません）。

**設定方法**:
1. Raycastを開く
2. 拡張機能を選択
3. `⌘,` (Command + Comma) で Preferences を開く
4. 各パラメータを設定

**Okan Tasks 拡張機能の設定項目**:
- **スプレッドシートID**: おかんスプレッドシートのID
- **シート名**: タスクが記載されているシートの名前
- **シートGID**: シートのGID (URLのgid=の後の数字)
- **あなたの名前**: スプレッドシートの列ヘッダーと完全一致させること
- **通知間隔**: 通知を送る間隔 (デフォルト: 1時間)

詳細は各拡張機能のREADMEを参照してください。

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
