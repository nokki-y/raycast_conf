#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Prevent Sleep
# @raycast.mode compact

# Optional parameters:
# @raycast.icon ☕
# @raycast.packageName System Control
# @raycast.argument1 { "type": "dropdown", "placeholder": "Action", "data": [{"title": "Start", "value": "start"}, {"title": "Stop", "value": "stop"}, {"title": "Status", "value": "status"}] }

# Documentation:
# @raycast.description スクリーンセーバーとスリープを防止します
# @raycast.author nokki_y

ACTION="$1"
CAFFEINE_PID_FILE="/tmp/raycast_caffeinate.pid"

start_prevent_sleep() {
    # 既に実行中かチェック
    if [ -f "$CAFFEINE_PID_FILE" ]; then
        PID=$(cat "$CAFFEINE_PID_FILE")
        if ps -p "$PID" > /dev/null 2>&1; then
            echo "⚠️ 既に実行中です (PID: $PID)"
            exit 0
        else
            # PIDファイルがあるが、プロセスが存在しない場合は削除
            rm -f "$CAFFEINE_PID_FILE"
        fi
    fi
    
    # caffeinateを開始（ディスプレイとシステムスリープを防止）
    caffeinate -di &
    CAFFEINATE_PID=$!
    
    # PIDを保存
    echo "$CAFFEINATE_PID" > "$CAFFEINE_PID_FILE"
    
    echo "☕ スリープ防止を開始しました (PID: $CAFFEINATE_PID)"
    echo "💡 停止するには 'Prevent Sleep → Stop' を実行してください"
}

stop_prevent_sleep() {
    if [ -f "$CAFFEINE_PID_FILE" ]; then
        PID=$(cat "$CAFFEINE_PID_FILE")
        if ps -p "$PID" > /dev/null 2>&1; then
            kill "$PID"
            rm -f "$CAFFEINE_PID_FILE"
            echo "✅ スリープ防止を停止しました"
        else
            rm -f "$CAFFEINE_PID_FILE"
            echo "⚠️ プロセスが見つかりません"
        fi
    else
        echo "⚠️ スリープ防止は実行されていません"
    fi
}

check_status() {
    if [ -f "$CAFFEINE_PID_FILE" ]; then
        PID=$(cat "$CAFFEINE_PID_FILE")
        if ps -p "$PID" > /dev/null 2>&1; then
            echo "☕ スリープ防止は実行中です (PID: $PID)"
            
            # プロセスの実行時間を取得
            RUNTIME=$(ps -o etime= -p "$PID" | xargs)
            echo "⏱️ 実行時間: $RUNTIME"
        else
            rm -f "$CAFFEINE_PID_FILE"
            echo "⭕ スリープ防止は実行されていません"
        fi
    else
        echo "⭕ スリープ防止は実行されていません"
    fi
}

case "$ACTION" in
    "start")
        start_prevent_sleep
        ;;
    "stop")
        stop_prevent_sleep
        ;;
    "status")
        check_status
        ;;
    *)
        echo "❌ 無効なアクション: $ACTION"
        echo "使用方法: start, stop, status"
        exit 1
        ;;
esac