#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Prevent Sleep Timer
# @raycast.mode compact

# Optional parameters:
# @raycast.icon ⏰
# @raycast.packageName System Control
# @raycast.argument1 { "type": "text", "placeholder": "分数を入力 (例: 30, 60, 120)" }

# Documentation:
# @raycast.description 指定時間だけスクリーンセーバーとスリープを防止します
# @raycast.author nokki_y

MINUTES="$1"
CAFFEINE_PID_FILE="/tmp/raycast_caffeinate_timer.pid"

# 数値チェック
if ! [[ "$MINUTES" =~ ^[0-9]+$ ]]; then
    echo "❌ 有効な分数を入力してください (例: 30, 60, 120)"
    exit 1
fi

# 既に実行中のタイマーがあるかチェック
if [ -f "$CAFFEINE_PID_FILE" ]; then
    PID=$(cat "$CAFFEINE_PID_FILE")
    if ps -p "$PID" > /dev/null 2>&1; then
        echo "⚠️ 既にタイマーが実行中です"
        echo "💡 停止するには 'Prevent Sleep → Stop' を使用してください"
        exit 0
    else
        rm -f "$CAFFEINE_PID_FILE"
    fi
fi

# 時間計算
SECONDS=$((MINUTES * 60))
HOURS=$((MINUTES / 60))
REMAINING_MINUTES=$((MINUTES % 60))

# 表示用の時間文字列を作成
if [ $HOURS -gt 0 ]; then
    if [ $REMAINING_MINUTES -gt 0 ]; then
        TIME_STRING="${HOURS}時間${REMAINING_MINUTES}分"
    else
        TIME_STRING="${HOURS}時間"
    fi
else
    TIME_STRING="${MINUTES}分"
fi

# caffeinateをタイマー付きで開始
caffeinate -di -t "$SECONDS" &
CAFFEINATE_PID=$!

# PIDを保存
echo "$CAFFEINATE_PID" > "$CAFFEINE_PID_FILE"

echo "⏰ ${TIME_STRING}のスリープ防止を開始しました"
echo "☕ スクリーンセーバーとスリープが無効化されています"
echo "💡 手動で停止するには 'Prevent Sleep → Stop' を実行してください"

# 終了時刻を計算して表示
if command -v date > /dev/null 2>&1; then
    END_TIME=$(date -v "+${MINUTES}M" "+%H:%M")
    echo "⏱️ 終了予定時刻: $END_TIME"
fi