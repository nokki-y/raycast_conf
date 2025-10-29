#!/bin/bash

# おかんタスク Raycast拡張機能 インストールスクリプト

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
EXTENSION_NAME="okan-tasks-production"
RAYCAST_EXTENSIONS_DIR="$HOME/.config/raycast/extensions"
INSTALL_TARGET="$RAYCAST_EXTENSIONS_DIR/$EXTENSION_NAME"

echo "🔨 おかんタスク Raycast拡張機能をインストールします..."
echo ""

# Raycast拡張機能ディレクトリが存在するか確認
if [ ! -d "$RAYCAST_EXTENSIONS_DIR" ]; then
    echo "❌ エラー: Raycastがインストールされていないか、拡張機能ディレクトリが見つかりません"
    echo "   $RAYCAST_EXTENSIONS_DIR"
    exit 1
fi

# 既存のインストールを削除
if [ -d "$INSTALL_TARGET" ]; then
    echo "🗑️  既存のインストールを削除中..."
    rm -rf "$INSTALL_TARGET"
fi

# 拡張機能をコピー
echo "📦 拡張機能をインストール中..."
cp -r "$SCRIPT_DIR" "$INSTALL_TARGET"

# Raycastを再起動
echo "🔄 Raycastを再起動中..."
killall Raycast 2>/dev/null || true
sleep 2
open -a Raycast

echo ""
echo "✅ インストール完了！"
echo ""
echo "📋 次のステップ:"
echo "1. Raycast を開く (⌘ + Space)"
echo "2. 'Check Okan Tasks' と入力"
echo "3. 設定を開く (⌘ + K → Configure Command)"
echo "4. 以下の情報を入力:"
echo "   - Spreadsheet ID"
echo "   - Sheet Name"
echo "   - Sheet GID"
echo "   - My Name"
echo ""
