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

# distディレクトリ全体をコピー
cp -r "$PROJECT_DIR/dist" "$RELEASE_DIR/$RELEASE_NAME/"

# assetsをコピー
cp -r "$PROJECT_DIR/assets" "$RELEASE_DIR/$RELEASE_NAME/"

# package.jsonをコピー（メタデータとして必要）
cp "$PROJECT_DIR/package.json" "$RELEASE_DIR/$RELEASE_NAME/"

# .authディレクトリの構造だけ作成（空）
mkdir -p "$RELEASE_DIR/$RELEASE_NAME/.auth"

# ユーザー向けガイドを作成
cat > "$RELEASE_DIR/$RELEASE_NAME/INSTALL.md" <<'EOF'
# おかんタスク確認 - インストールガイド

## 📋 前提条件

- macOS
- Raycast がインストール済み

## 🚀 インストール手順

### ステップ1: 認証情報ファイルの配置

管理者から受け取った `credentials.json` を `.auth/` ディレクトリに配置します：

```bash
# ダウンロードフォルダから移動する場合
mv ~/Downloads/credentials.json .auth/
```

### ステップ2: 初回認証

以下のコマンドを実行して、Google認証を行います：

```bash
open setup-auth.html
```

ブラウザが開いたら：
1. Googleアカウントでログイン
2. アクセス許可を承認
3. 認証が完了すると、`.auth/token.json` が自動作成されます

**注意**: 認証は初回のみ必要です。以降は自動的にトークンがリフレッシュされます。

### ステップ3: Raycastに拡張機能をインストール

1. Raycast Preferences を開く (⌘ + ,)
2. **Extensions** タブを選択
3. **+** ボタン → **Add Extension** をクリック
4. この `okan-tasks-raycast` フォルダを選択
5. **Install Extension** をクリック

### ステップ4: 設定

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

### ステップ5: 動作確認

1. Raycastを開く (⌘ + Space)
2. `Check Okan Tasks` と入力
3. タスク一覧が表示されれば成功！

## ✨ 使い方

- **期限切れ・2営業日以内のタスク**が自動的に表示されます
- タスクを選択して Enter → スプレッドシートの該当セルが開きます
- **完了**・**対象外**のタスクは自動的に除外されます

## ❓ トラブルシューティング

### 認証エラーが出る

`.auth/credentials.json` が正しく配置されているか確認してください。

### タスクが表示されない

1. Spreadsheet ID が正しいか
2. Sheet Name が正しいか
3. My Name がスプレッドシートの列ヘッダーと完全一致しているか

### その他の問題

管理者に連絡してください。
EOF

echo ""
echo "✅ リリースパッケージの作成が完了しました！"
echo ""
echo "📁 パッケージの場所: $RELEASE_DIR/$RELEASE_NAME"
echo ""
echo "📤 配布方法:"
echo "1. $RELEASE_DIR/$RELEASE_NAME フォルダを配布先に送付"
echo "2. credentials.json を別途共有"
echo "3. 配布先にINSTALL.mdの手順を実行してもらう"
echo ""
