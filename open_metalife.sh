#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Open MetaLife
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🌐
# @raycast.packageName Browser
# @raycast.argument1 { "type": "text", "placeholder": "URL (optional)", "optional": true }

# Documentation:
# @raycast.description MetaLifeのスペースをChromeで開きます
# @raycast.author nokki_y

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# .envファイルを読み込む
if [ -f "$SCRIPT_DIR/.env" ]; then
    source "$SCRIPT_DIR/.env"
else
    echo "❌ エラー: .env ファイルが見つかりません"
    echo "💡 .env.example をコピーして .env を作成し、設定してください:"
    echo "   cp $SCRIPT_DIR/.env.example $SCRIPT_DIR/.env"
    exit 1
fi

# 環境変数チェック
if [ -z "$METALIFE_SPACE_ID" ]; then
    echo "❌ エラー: METALIFE_SPACE_ID が設定されていません"
    echo "💡 .env ファイルに METALIFE_SPACE_ID を設定してください"
    exit 1
fi

# デフォルトのMetaLife URL
DEFAULT_URL="https://app.metalife.co.jp/spaces/${METALIFE_SPACE_ID}"

# 引数があればそれを使用、なければデフォルトURL
URL="${1:-$DEFAULT_URL}"

# ChromeでURLを開く
open -a "Google Chrome" "$URL"

echo "🌐 MetaLifeを開きました"
