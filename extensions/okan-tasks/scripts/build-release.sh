#!/bin/bash

# リリース用パッケージをビルドするスクリプト

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR/.."
RELEASE_DIR="$PROJECT_DIR/release"
RELEASE_NAME="okan-tasks-raycast"

echo "🔨 リリースパッケージをビルドしています..."

# クリーンアップ
rm -rf "$RELEASE_DIR"
mkdir -p "$RELEASE_DIR"

# プロダクションビルド
echo "📦 拡張機能をビルド中..."
cd "$PROJECT_DIR"
npm run build

# Raycastビルド済みディレクトリをベースにする
RAYCAST_BUILD_DIR="$HOME/.config/raycast/extensions/raycast-okan"
if [ ! -d "$RAYCAST_BUILD_DIR" ]; then
    echo "❌ エラー: Raycastビルド出力が見つかりません: $RAYCAST_BUILD_DIR"
    echo "   拡張機能を一度ビルドしてください"
    exit 1
fi

echo "📋 ビルド済み拡張機能をコピー中..."
mkdir -p "$RELEASE_DIR"
cp -r "$RAYCAST_BUILD_DIR" "$RELEASE_DIR/$RELEASE_NAME"

# authディレクトリをコピー（認証済みの状態で配布）
echo "🔐 認証情報をコピー中..."
if [ -d "$PROJECT_DIR/auth" ] && [ -f "$PROJECT_DIR/auth/token.json" ]; then
    # ビルド済みディレクトリ内のauthを上書き
    cp -r "$PROJECT_DIR/auth" "$RELEASE_DIR/$RELEASE_NAME/"
    echo "✅ 認証情報をコピーしました（エンドユーザーは認証不要）"
else
    echo "⚠️  警告: auth/token.json が見つかりません"
    echo "   npm run setup-auth を先に実行してください"
    exit 1
fi

# インストールスクリプトをコピー
echo "📝 インストールスクリプトをコピー中..."
cp "$SCRIPT_DIR/install.sh" "$RELEASE_DIR/$RELEASE_NAME/"
chmod +x "$RELEASE_DIR/$RELEASE_NAME/install.sh"

# ユーザー向けガイドを作成
cat > "$RELEASE_DIR/$RELEASE_NAME/INSTALL.md" <<'EOF'
# おかんタスク確認 - インストールガイド

## 📋 前提条件

- macOS
- Raycast がインストール済み

## 🚀 インストール手順（推奨）

### 方法1: インストールスクリプトを使用（簡単）

1. Zipファイルを解凍
2. ターミナルで解凍したフォルダに移動
3. 以下のコマンドを実行:
   ```bash
   ./install.sh
   ```
4. Raycastが自動的に再起動されます

**注意**: 認証情報は既に含まれているため、認証作業は不要です！

### 方法2: 手動インストール

1. 解凍したフォルダ全体を以下の場所にコピー:
   ```bash
   ~/.config/raycast/extensions/okan-tasks-production
   ```
2. Raycastを再起動

### ステップ2: 設定

1. Raycastを開く (⌘ + Space)
2. `Check Okan Tasks` と入力
3. 拡張機能の設定を開く (⌘ + K → Preferences)
4. 以下の項目を入力：

| 項目 | 説明 | 取得方法 |
|------|------|---------|
| **Spreadsheet ID** | スプレッドシートのID | URLから: `https://docs.google.com/spreadsheets/d/{ここ}/` |
| **Sheet Name** | シート名 | 例: `【Todo】タスク一覧` |
| **Sheet GID** | シートのGID | URLから: `?gid={ここ}` |
| **My Name** | あなたの名前 | スプレッドシートの列ヘッダーと完全一致 |

### ステップ3: 動作確認

1. Raycastを開く (⌘ + Space)
2. `Check Okan Tasks` と入力
3. タスク一覧が表示されれば成功！

## ✨ 使い方

- **期限切れ・2営業日以内のタスク**が自動的に表示されます
- タスクを選択して Enter → スプレッドシートの該当セルが開きます
- **完了**・**対象外**のタスクは自動的に除外されます
- アクセストークンは**自動的にリフレッシュ**されるため、メンテナンス不要

## ❓ トラブルシューティング

### タスクが表示されない

1. Spreadsheet ID が正しいか
2. Sheet Name が正しいか（大文字小文字、スペースに注意）
3. My Name がスプレッドシートの列ヘッダーと完全一致しているか

### 401 Unauthorized エラーが出る

通常は自動リフレッシュされますが、もしエラーが出た場合は管理者に連絡してください。

### その他の問題

管理者に連絡してください。
EOF

echo ""
echo "✅ リリースパッケージの作成が完了しました！"
echo ""
echo "📁 パッケージの場所: $RELEASE_DIR/$RELEASE_NAME"
echo ""
echo "📤 配布方法:"
echo "1. $RELEASE_DIR/$RELEASE_NAME フォルダをZipに圧縮"
echo "   cd $RELEASE_DIR && zip -r okan-tasks-raycast.zip okan-tasks-raycast/"
echo "2. okan-tasks-raycast.zip を配布先に送付"
echo "3. 配布先にINSTALL.mdの手順を実行してもらう"
echo ""
echo "⚠️  重要: 認証情報が含まれているため、配布先は信頼できる相手のみに限定してください"
echo ""
