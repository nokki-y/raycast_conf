#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Open おかん
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 📊
# @raycast.packageName Web Browser

# Documentation:
# @raycast.description おかんスプレッドシートをChromeで開きます
# @raycast.author nokki-y
# @raycast.authorURL https://github.com/nokki-y

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
if [ -z "$OKAN_SPREADSHEET_ID" ]; then
    echo "❌ エラー: OKAN_SPREADSHEET_ID が設定されていません"
    echo "💡 .env ファイルに OKAN_SPREADSHEET_ID を設定してください"
    exit 1
fi

# スプレッドシートURL
if [ -n "$OKAN_SHEET_GID" ]; then
    URL="https://docs.google.com/spreadsheets/d/${OKAN_SPREADSHEET_ID}/edit?gid=${OKAN_SHEET_GID}#gid=${OKAN_SHEET_GID}"
else
    URL="https://docs.google.com/spreadsheets/d/${OKAN_SPREADSHEET_ID}/edit"
fi

# ChromeでURLを開く（既存のタブがあればアクティブにする）
osascript <<EOF
tell application "Google Chrome"
    activate
    set foundTab to false
    set targetURL to "$URL"

    -- すべてのウィンドウとタブを検索（完全一致）
    repeat with w in windows
        set tabIndex to 1
        repeat with t in tabs of w
            if URL of t starts with targetURL then
                set active tab index of w to tabIndex
                set index of w to 1
                set foundTab to true
                exit repeat
            end if
            set tabIndex to tabIndex + 1
        end repeat
        if foundTab then exit repeat
    end repeat

    -- タブが見つからなかった場合は新しいタブで開く
    if not foundTab then
        tell window 1
            make new tab with properties {URL:targetURL}
        end tell
    end if
end tell
EOF

if [ $? -eq 0 ]; then
    echo "📊 おかんスプレッドシートを開きました"
else
    echo "❌ エラー: Chromeの起動に失敗しました"
    exit 1
fi
