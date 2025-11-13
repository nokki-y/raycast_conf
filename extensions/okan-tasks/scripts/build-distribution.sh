#!/bin/bash

#############################################
# Okan Tasks 配布用zipビルドスクリプト
#############################################
# 機能:
# - 認証情報を含む配布用zipファイルを作成
# - Google Driveなどでの配布用
# - GitHubリリース後にローカルで実行
#############################################

set -e

# 色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ディレクトリ設定
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
EXTENSION_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DIST_DIR="$EXTENSION_DIR/distribution"
VERSION_FILE="$EXTENSION_DIR/VERSION"

# 関数: エラーメッセージ
error() {
    echo -e "${RED}❌ エラー: $1${NC}" >&2
    exit 1
}

# 関数: 警告メッセージ
warn() {
    echo -e "${YELLOW}⚠️  警告: $1${NC}"
}

# 関数: 成功メッセージ
success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# 関数: 情報メッセージ
info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# バージョン取得
if [ ! -f "$VERSION_FILE" ]; then
    error "VERSIONファイルが見つかりません: $VERSION_FILE"
fi

VERSION=$(cat "$VERSION_FILE")
PACKAGE_NAME="okan-tasks-v$VERSION"
DIST_PACKAGE_NAME="okan-tasks-v$VERSION-dist"

echo ""
echo "========================================"
echo "  配布用zip作成: v$VERSION"
echo "========================================"
echo ""

# 認証情報チェック
info "認証情報をチェック中..."

AUTH_DIR="$EXTENSION_DIR/assets/.auth"

if [ ! -d "$AUTH_DIR" ]; then
    error "認証ディレクトリが見つかりません: $AUTH_DIR"
fi

if [ ! -f "$AUTH_DIR/credentials.json" ]; then
    error "credentials.jsonが見つかりません: $AUTH_DIR/credentials.json"
fi

if [ ! -f "$AUTH_DIR/token.json" ]; then
    error "token.jsonが見つかりません: $AUTH_DIR/token.json"
fi

success "認証情報チェック完了"

# Raycastビルド出力チェック
info "ビルド出力をチェック中..."

RAYCAST_BUILD_DIR="$HOME/.config/raycast/extensions/raycast-okan"

if [ ! -d "$RAYCAST_BUILD_DIR" ]; then
    error "Raycastビルド出力が見つかりません: $RAYCAST_BUILD_DIR
    
先に以下を実行してください:
  cd $EXTENSION_DIR
  npm run build"
fi

success "ビルド出力チェック完了"

# 配布ディレクトリ作成
info "配布ディレクトリを準備中..."

rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR"

# ビルド済み拡張機能をコピー
info "拡張機能をコピー中..."
cp -r "$RAYCAST_BUILD_DIR" "$DIST_DIR/$PACKAGE_NAME"

# 認証情報をコピー
info "認証情報を追加中..."
mkdir -p "$DIST_DIR/$PACKAGE_NAME/assets"
cp -r "$AUTH_DIR" "$DIST_DIR/$PACKAGE_NAME/assets/"

success "認証情報を追加しました"

# バージョンファイルを追加
echo "$VERSION" > "$DIST_DIR/$PACKAGE_NAME/VERSION"

# インストールガイドを生成
info "インストールガイドを生成中..."

cat > "$DIST_DIR/$PACKAGE_NAME/INSTALL.md" <<EOF
# おかんタスク確認 v$VERSION - インストールガイド

## 📋 前提条件

- macOS
- Raycast がインストール済み

## 🚀 インストール手順

### ステップ1: Zipファイルを解凍

1. \`$DIST_PACKAGE_NAME.zip\` を解凍
2. \`$PACKAGE_NAME\` フォルダが作成されます

**注意**: 認証情報は既に含まれているため、認証作業は不要です！

### ステップ2: Raycastにインポート

1. Raycast Preferences を開く (⌘ + ,)
2. **Extensions** タブを選択
3. 右上の **"+"** ボタンをクリック
4. **"Import Extension"** を選択
5. 解凍した \`$PACKAGE_NAME\` フォルダを選択
6. インポート完了！

### ステップ3: 設定

1. Raycastを開く (⌘ + Space)
2. \`Check Okan Tasks\` と入力
3. 拡張機能の設定を開く (⌘ + K → Preferences)
4. 以下の項目を入力：

| 項目 | 説明 | デフォルト値 |
|------|------|-------------|
| **Spreadsheet ID** | スプレッドシートのID | 設定済み（変更不要） |
| **Sheet Name** | シート名 | 設定済み（変更不要） |
| **Sheet GID** | シートのGID | 設定済み（変更不要） |
| **My Name** | あなたの名前 | **要設定**（スプレッドシートの列ヘッダーと一致） |
| **通知間隔** | 通知を送る間隔 | 1時間（推奨） |

**重要**: **My Name** のみ必ず設定してください。スプレッドシートの列ヘッダー（担当者名）と完全一致させる必要があります。

### ステップ4: バックグラウンド通知を有効化（推奨）

デスクトップ通知を受け取りたい場合：

1. Raycast Preferences を開く (⌘ + ,)
2. **Extensions** → **Okan Tasks** → **Notify Okan Tasks** を探す
3. **Background Refresh** トグルを **ON** にする

これにより以下の通知が有効になります：
- 期日切れ・今日締切のタスクがあれば通知
- 通知間隔は設定で変更可能（デフォルト: 1時間）
- アラート形式（音なし、2ボタン方式）
  - **「OK」**: アラートを閉じる
  - **「タスクを確認」**: Raycastのタスク一覧を直接開く

### ステップ5: 動作確認

1. Raycastを開く (⌘ + Space)
2. \`Check Okan Tasks\` と入力
3. タスク一覧が表示されれば成功！

## ✨ 使い方

### 基本機能
- **期限切れ・2営業日以内のタスク**が自動的に表示されます
- タスクを選択して Enter → スプレッドシートの該当セルが開きます
- **完了**・**対象外**のタスクは自動的に除外されます
- アクセストークンは**自動的にリフレッシュ**されるため、メンテナンス不要

### 通知機能
- **デスクトップ通知**で期日切れタスクを見逃さない（Background Refresh有効時）
- **アラート形式**（音なし、2ボタン方式）
  - **「タスクを確認」**: Raycastのタスク一覧を直接開く
  - **「OK」**: アラートを閉じる

## ❓ トラブルシューティング

### 初期設定を間違えた・やり直したい

設定を変更する方法：

1. Raycastを開く (⌘ + Space)
2. \`Check Okan Tasks\` と入力
3. **⌘ + K** を押してアクションメニューを開く
4. **「Configure Extension」** を選択
5. 設定値を修正して保存

### タスクが表示されない

1. **My Name** がスプレッドシートの列ヘッダーと完全一致しているか確認
   - 大文字小文字、スペースに注意
   - スプレッドシートの1行目（列ヘッダー）と完全一致させる

### 通知が来ない

1. **Background Refresh** が有効になっているか確認
   - Raycast Preferences → Extensions → Notify Okan Tasks
   - トグルが **ON** になっているか確認

2. 通知の条件を確認
   - 期日切れまたは今日締切のタスクがある場合のみ通知されます

### その他の問題

管理者に連絡してください。

---

**バージョン**: v$VERSION
**リリース日**: $(date +"%Y-%m-%d")
EOF

success "インストールガイド生成完了"

# Zipファイルを作成
info "Zipファイルを作成中..."

cd "$DIST_DIR"
zip -r "$DIST_PACKAGE_NAME.zip" "$PACKAGE_NAME" > /dev/null

success "Zipファイル作成完了"

# ファイルサイズを取得
ZIP_SIZE=$(du -sh "$DIST_DIR/$DIST_PACKAGE_NAME.zip" | cut -f1)

echo ""
echo "========================================"
success "配布用zip作成完了！"
echo "========================================"
echo ""
info "📦 配布ファイル:"
echo "   $DIST_DIR/$DIST_PACKAGE_NAME.zip"
echo "   サイズ: $ZIP_SIZE"
echo ""
info "📋 次のステップ:"
echo "   1. このzipファイルをGoogle Driveなどにアップロード"
echo "   2. エンドユーザーに共有リンクを送信"
echo "   3. ユーザーはzipを解凍してRaycastにインポート"
echo ""
warn "⚠️  重要: 認証情報が含まれているため、配布先は信頼できる相手のみに限定してください"
echo ""

