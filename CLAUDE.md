# Raycast Configuration Repository

このリポジトリは、Raycastの拡張機能とスクリプトコマンドを管理するためのリポジトリです。

## プロジェクト構成

```
raycast_conf/
├── commands/              # Raycastスクリプトコマンド
│   ├── scripts/          # ビルドスクリプト
│   │   └── build.sh     # コマンドビルドスクリプト
│   ├── *.sh             # コマンドテンプレート（プレースホルダー含む）
│   ├── release/         # ビルド出力（gitignore）
│   └── .env             # 環境変数（gitignore）
├── extensions/           # Raycast拡張機能
│   └── okan-tasks/      # Okanタスク管理拡張
└── scripts/             # プロジェクト全体のスクリプト
```

## コマンド（commands/）の開発における重要な注意点

### ⚠️ Raycastスクリプトコマンドの実行の仕組み

**Raycastは、スクリプトコマンドを実行する際に、元のファイルを別の場所（`~/.config/raycast/script-commands/`）にコピーしてから実行します。**

この仕組みにより、以下の問題が発生します：

#### ❌ 動作しないパターン

```bash
# スクリプト内で.envファイルを読み込む
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.env"  # ❌ .envファイルが見つからない！
```

**理由**: Raycastがスクリプトをコピーした際、.envファイルは一緒にコピーされないため、実行時にファイルが見つかりません。

#### ✅ 正しいパターン

```bash
# プレースホルダーを使用
URL="https://app.metalife.co.jp/spaces/__METALIFE_SPACE_ID__"

# ビルド時に実際の値に置換される
# → URL="https://app.metalife.co.jp/spaces/AEGHlYcrIfPQ5XpCZspE"
```

## ビルドシステム

### プレースホルダーの規約

環境変数を埋め込む場合は、以下の命名規則に従います：

- `__VARIABLE_NAME__` 形式
- 例: `__METALIFE_SPACE_ID__`, `__GOOGLE_ACCOUNT_INDEX__`

### ビルドプロセス

1. **テンプレートファイル作成**
   - `commands/` 配下に `*.sh` ファイルを作成
   - プレースホルダーを使用して値を埋め込む箇所を指定

2. **ビルドスクリプトに置換処理を追加**
   - `commands/scripts/build.sh` に置換ロジックを追加
   - `.env` から値を読み込み
   - プレースホルダーを実際の値に置換

3. **ビルド実行**
   ```bash
   npm run build:commands
   ```

4. **出力確認**
   - `commands/release/` 配下に完全な値が埋め込まれたファイルが生成される
   - このディレクトリは `.gitignore` されており、機密情報を安全に管理

### 既存のプレースホルダー

- `__DROPDOWN_DATA__`: GitHubリポジトリのドロップダウンデータ生成
- `__METALIFE_SPACE_ID__`: MetaLifeスペースID
- `__GOOGLE_ACCOUNT_INDEX__`: Googleアカウントインデックス（デフォルト: 0）

### 新しいコマンドの追加手順

1. **テンプレートファイルを作成**
   ```bash
   # commands/my_command.sh
   URL="https://example.com/__MY_VARIABLE__"
   ```

2. **ビルドスクリプトに置換処理を追加**
   ```bash
   # commands/scripts/build.sh
   if echo "$content" | grep -q "__MY_VARIABLE__"; then
       needs_replacement=true
       content=$(echo "$content" | sed "s|__MY_VARIABLE__|${MY_VARIABLE}|g")
       echo "   ✓ MY_VARIABLE を埋め込みました"
   fi
   ```

3. **環境変数を設定**
   ```bash
   # commands/.env
   MY_VARIABLE=actual_value
   ```

4. **ビルドして動作確認**
   ```bash
   npm run build:commands
   bash commands/release/my_command.sh
   ```

### セキュリティとベストプラクティス

- ✅ 機密情報は `.env` に記載し、Git管理から除外
- ✅ `commands/release/` は `.gitignore` に含める
- ✅ プレースホルダーを使用したテンプレートファイルのみをGit管理
- ✅ ビルドプロセスで値を注入する仕組みを統一
- ❌ スクリプト内で外部ファイル（.envなど）を直接読み込まない

## リリース管理

### Commands のリリース

- **ディレクトリ**: `commands/`
- **バージョン管理**: `commands/VERSION`
- **リリースコマンド**: `npm run release:commands [major|minor|patch|X.Y.Z]`
- **タグ名**: `commands-vX.Y.Z`
- **リリース内容**:
  - ビルド済みスクリプトコマンド（全て）
  - README.md（インストールガイド）
  - RELEASE_NOTES.md
  - Zipファイル（配布用）

### Extensions のリリース

#### Okan Tasks 拡張機能

- **ディレクトリ**: `extensions/okan-tasks/`
- **バージョン管理**: `extensions/okan-tasks/VERSION`
- **リリースコマンド**: `npm run release:okan [major|minor|patch|X.Y.Z]`
- **タグ名**: `okan-vX.Y.Z`
- **機能**:
  - Google Sheets API連携
  - タスク通知機能
  - 通知ダイアログの重複防止（ファイルベースロック）
  - GitHub Release自動作成

## npm スクリプト

```bash
# コマンドのビルド
npm run build:commands

# コマンドのリリース
npm run release:commands patch   # パッチバージョンアップ
npm run release:commands minor   # マイナーバージョンアップ
npm run release:commands major   # メジャーバージョンアップ
npm run release:commands 1.0.0   # 特定バージョン指定

# Okan Tasks拡張のリリース
npm run release:okan patch
npm run release:okan minor
npm run release:okan major
npm run release:okan 1.0.0

# セキュリティチェック
npm run security:check
```

## トラブルシューティング

### コマンドが動作しない場合

1. **ビルドを実行したか確認**
   ```bash
   npm run build:commands
   ```

2. **Raycastの設定を確認**
   - Raycast Preferences → Extensions → Script Commands
   - `commands/release/` ディレクトリが追加されているか確認

3. **環境変数が正しく設定されているか確認**
   ```bash
   cat commands/.env
   ```

### 拡張機能のビルドエラー

1. **依存関係をインストール**
   ```bash
   cd extensions/okan-tasks
   npm install
   ```

2. **認証情報を確認**
   ```bash
   ls -la extensions/okan-tasks/assets/.auth/
   # credentials.json と token.json が存在するか確認
   ```