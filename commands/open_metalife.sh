#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Open MetaLife
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🌐
# @raycast.packageName Web Browser

# Documentation:
# @raycast.description MetaLifeのスペースをChromeで開きます
# @raycast.author nokki-y
# @raycast.authorURL https://github.com/nokki-y

# MetaLife URL（ビルド時に置換される）
URL="https://app.metalife.co.jp/spaces/__METALIFE_SPACE_ID__"

# ChromeでURLを開く（既存のタブがあればアクティブにする）
osascript <<EOF
tell application "Google Chrome"
    activate
    set foundTab to false
    set targetURL to "$URL"

    -- ウィンドウが存在する場合のみタブを検索
    if (count of windows) > 0 then
        -- すべてのウィンドウとタブを検索
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
    else
        -- ウィンドウが存在しない場合は新しいウィンドウで開く
        make new window with properties {URL:targetURL}
    end if
end tell
EOF

if [ $? -eq 0 ]; then
    echo "🌐 MetaLifeを開きました"
else
    echo "❌ エラー: Chromeの起動に失敗しました"
    exit 1
fi
