#!/bin/bash

#############################################
# Okan Tasks 開発ビルドスクリプト
#############################################
# 機能:
# - 開発モードでビルド（1分間隔オプション有効）
# - release/devにビルド成果物を出力
#############################################

set -e

# 色定義
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ディレクトリ設定
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
EXTENSION_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
RELEASE_DIR="$EXTENSION_DIR/release/dev"

echo -e "${BLUE}🔨 開発ビルドを開始します...${NC}"
echo ""

# 拡張機能ディレクトリに移動
cd "$EXTENSION_DIR"

# 開発ビルド実行
echo -e "${BLUE}📦 開発モードでビルド中...${NC}"
npm run build:dev

# release/devディレクトリをクリーンアップ
echo ""
echo -e "${BLUE}📁 release/devディレクトリを準備中...${NC}"
rm -rf "$RELEASE_DIR"
mkdir -p "$RELEASE_DIR"

# Raycastビルド済みディレクトリからコピー
RAYCAST_BUILD_DIR="$HOME/.config/raycast/extensions/raycast-okan"

if [ ! -d "$RAYCAST_BUILD_DIR" ]; then
    echo -e "${RED}❌ エラー: Raycastビルド出力が見つかりません${NC}"
    echo "   場所: $RAYCAST_BUILD_DIR"
    exit 1
fi

echo -e "${BLUE}📋 ビルド成果物をコピー中...${NC}"
cp -r "$RAYCAST_BUILD_DIR" "$RELEASE_DIR/raycast-okan"

# 注意: 開発ビルドには認証情報を含めません
# 認証情報は元の assets/.auth/ から直接読み込まれます

# ファイルサイズを取得
TOTAL_SIZE=$(du -sh "$RELEASE_DIR" | cut -f1)

echo ""
echo -e "${GREEN}✅ 開発ビルドが完了しました！${NC}"
echo ""
echo "📁 出力先: $RELEASE_DIR"
echo "📦 サイズ: $TOTAL_SIZE"
echo ""
echo "ファイル一覧:"
ls -lh "$RELEASE_DIR/raycast-okan" | tail -n +2
echo ""
echo -e "${GREEN}🎉 完了！${NC}"
