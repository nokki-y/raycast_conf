#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Open Gmail
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 📧
# @raycast.packageName Web Browser

# Documentation:
# @raycast.description Gmailを開く
# @raycast.author nokki-y
# @raycast.authorURL https://github.com/nokki-y

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# .envファイルを読み込む（存在する場合）
if [ -f "$SCRIPT_DIR/../.env" ]; then
    source "$SCRIPT_DIR/../.env"
fi

# Googleアカウントインデックス（デフォルト: 0）
ACCOUNT_INDEX="${GOOGLE_ACCOUNT_INDEX:-0}"

# Gmail URL
URL="https://mail.google.com/mail/u/${ACCOUNT_INDEX}/#inbox"

# ChromeでURLを開く（既存のタブがあればアクティブにする）
osascript <<EOF
tell application "Google Chrome"
    activate
    set foundTab to false
    set targetURL to "$URL"
    set targetDomain to "https://mail.google.com"

    -- すべてのウィンドウとタブを検索（ドメイン一致）
    repeat with w in windows
        set tabIndex to 1
        repeat with t in tabs of w
            if URL of t starts with targetDomain then
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
    echo "📧 Gmailを開きました"
else
    echo "❌ エラー: Chromeの起動に失敗しました"
    exit 1
fi
