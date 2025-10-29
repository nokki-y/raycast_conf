#!/bin/bash

# .authディレクトリをRaycast拡張ディレクトリにコピーするスクリプト

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_AUTH_DIR="$SCRIPT_DIR/../.auth"
RAYCAST_EXT_DIR="$HOME/.config/raycast/extensions/raycast-okan/.auth"

echo "🔄 認証情報をRaycast拡張ディレクトリに同期します..."

# Raycastディレクトリが存在するか確認
if [ ! -d "$HOME/.config/raycast/extensions/raycast-okan" ]; then
    echo "❌ Raycast拡張ディレクトリが見つかりません"
    echo "先に 'npm run dev' を実行して拡張機能をインストールしてください"
    exit 1
fi

# .authディレクトリが存在するか確認
if [ ! -d "$PROJECT_AUTH_DIR" ]; then
    echo "❌ .authディレクトリが見つかりません: $PROJECT_AUTH_DIR"
    echo "先に 'npm run setup-auth' を実行してください"
    exit 1
fi

# ディレクトリ作成
mkdir -p "$RAYCAST_EXT_DIR"

# ファイルをコピー
cp "$PROJECT_AUTH_DIR"/* "$RAYCAST_EXT_DIR/" 2>/dev/null

if [ $? -eq 0 ]; then
    echo "✅ 認証情報を同期しました"
    echo "📁 コピー先: $RAYCAST_EXT_DIR"
else
    echo "❌ 認証情報のコピーに失敗しました"
    exit 1
fi
