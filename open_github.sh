#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Open GitHub
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🐙
# @raycast.packageName Web Browser
# @raycast.argument1 { "type": "dropdown", "placeholder": "Select Repository", "optional": true, "data": [{"title": "nokki-y", "value": ""}, {"title": "lmi-mcs/survey-hub", "value": "lmi-mcs/survey-hub"}] }

# Documentation:
# @raycast.description GitHubを開く
# @raycast.author nokki-y
# @raycast.authorURL https://github.com/nokki-y

# GitHub URL
if [ -n "$1" ] && [ "$1" != "" ]; then
    # リポジトリ選択時：リポジトリURL（完全一致で検索）
    URL="https://github.com/$1"
    SEARCH_MODE="exact"
else
    # Home選択時：nokki-yのプロフィール（ドメイン一致で検索）
    URL="https://github.com/nokki-y"
    SEARCH_MODE="domain"
fi

# ChromeでURLを開く（既存のタブがあればアクティブにする）
osascript <<EOF
tell application "Google Chrome"
    activate
    set foundTab to false
    set targetURL to "$URL"
    set searchMode to "$SEARCH_MODE"

    -- すべてのウィンドウとタブを検索
    repeat with w in windows
        set tabIndex to 1
        repeat with t in tabs of w
            set isMatch to false

            -- 検索モードに応じて一致判定
            if searchMode is "exact" then
                -- 完全一致（リポジトリ指定時）
                if URL of t starts with targetURL then
                    set isMatch to true
                end if
            else
                -- ドメイン一致（ホーム指定時）
                if URL of t starts with "https://github.com" then
                    set isMatch to true
                end if
            end if

            if isMatch then
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
    echo "🐙 GitHubを開きました"
else
    echo "❌ エラー: Chromeの起動に失敗しました"
    exit 1
fi
