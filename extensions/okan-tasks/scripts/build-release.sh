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

# 配布用ディレクトリに必要なファイルをコピー
echo "📋 配布用ファイルをコピー中..."
mkdir -p "$RELEASE_DIR/$RELEASE_NAME"

# distディレクトリ全体をコピー（Raycastビルド後の場所から）
RAYCAST_BUILD_DIR="$HOME/.config/raycast/extensions/raycast-okan"
if [ -d "$RAYCAST_BUILD_DIR" ]; then
    cp -r "$RAYCAST_BUILD_DIR" "$RELEASE_DIR/$RELEASE_NAME/dist"
else
    echo "❌ エラー: Raycastビルド出力が見つかりません: $RAYCAST_BUILD_DIR"
    exit 1
fi

# assetsをコピー
cp -r "$PROJECT_DIR/assets" "$RELEASE_DIR/$RELEASE_NAME/"

# package.jsonをコピー（メタデータとして必要）
cp "$PROJECT_DIR/package.json" "$RELEASE_DIR/$RELEASE_NAME/"

# .authディレクトリをコピー（認証済みの状態で配布）
echo "🔐 認証情報をコピー中..."
if [ -d "$PROJECT_DIR/.auth" ] && [ -f "$PROJECT_DIR/.auth/token.json" ]; then
    cp -r "$PROJECT_DIR/.auth" "$RELEASE_DIR/$RELEASE_NAME/"
    echo "✅ 認証情報をコピーしました（エンドユーザーは認証不要）"
else
    echo "⚠️  警告: .auth/token.json が見つかりません"
    echo "   npm run setup-auth を先に実行してください"
    exit 1
fi

# ユーザー向けガイドを作成
cat > "$RELEASE_DIR/$RELEASE_NAME/INSTALL.md" <<'EOF'
# おかんタスク確認 - インストールガイド

## 📋 前提条件

- macOS
- Raycast がインストール済み

## 🚀 インストール手順

### ステップ1: Raycastに拡張機能をインストール

1. Raycast Preferences を開く (⌘ + ,)
2. **Extensions** タブを選択
3. **+** ボタン → **Add Extension** をクリック
4. この `okan-tasks-raycast` フォルダを選択
5. **Install Extension** をクリック

**注意**: 認証情報は既に含まれているため、認証作業は不要です！

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
