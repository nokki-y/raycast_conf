#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Activate Google Meet
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 📹
# @raycast.packageName Web Browser

# Documentation:
# @raycast.description 開いているGoogle Meetタブをアクティブにする
# @raycast.author nokki-y
# @raycast.authorURL https://github.com/nokki-y

# ChromeでGoogle Meetタブを探してアクティブにする
osascript <<EOF
tell application "Google Chrome"
    activate
    set foundTab to false
    set targetDomain to "https://meet.google.com"

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

    -- タブが見つからなかった場合はメッセージを表示
    if not foundTab then
        return "not_found"
    end if
end tell
EOF

RESULT=$?

if [ $RESULT -eq 0 ]; then
    OUTPUT=$(osascript -e 'tell application "Google Chrome" to return "found"' 2>/dev/null)
    if [ "$OUTPUT" = "not_found" ]; then
        echo "⚠️ Google Meetのタブが見つかりませんでした"
        exit 1
    else
        echo "📹 Google Meetタブをアクティブにしました"
    fi
else
    echo "❌ エラー: Chromeの起動に失敗しました"
    exit 1
fi
