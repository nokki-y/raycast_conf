#!/bin/bash

# ============================================
# Raycast スクリプトコマンドのビルドスクリプト
# ============================================
#
# すべてのスクリプトコマンドを commands/release/ にビルドします。
# 環境変数のプレースホルダーがある場合は置換し、ない場合はそのままコピーします。
#
# Usage:
#   ./scripts/build-commands.sh
#

set -euo pipefail

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMANDS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="$(cd "$COMMANDS_DIR/.." && pwd)"
RELEASE_DIR="$COMMANDS_DIR/release"
ENV_FILE="$COMMANDS_DIR/.env"

echo "🔨 Raycast コマンドのビルドを開始します..."

# .envファイルの存在確認
if [ ! -f "$ENV_FILE" ]; then
    echo "❌ エラー: $ENV_FILE が見つかりません"
    echo "   commands/.env.example をコピーして .env を作成してください"
    exit 1
fi

# 環境変数を読み込む
source "$ENV_FILE"

# releaseディレクトリを作成（既存の場合はクリア）
if [ -d "$RELEASE_DIR" ]; then
    echo "📦 既存のreleaseディレクトリをクリアしています..."
    rm -rf "$RELEASE_DIR"
fi
mkdir -p "$RELEASE_DIR"

# ビルド対象のファイル数をカウント
total_files=0
processed_files=0

# すべての.shファイルを処理
for source_file in "$COMMANDS_DIR"/*.sh; do
    # ファイルが存在しない場合はスキップ
    [ -e "$source_file" ] || continue

    total_files=$((total_files + 1))
done

echo "📁 $total_files 個のコマンドを処理します..."
echo ""

# すべての.shファイルを処理
for source_file in "$COMMANDS_DIR"/*.sh; do
    # ファイルが存在しない場合はスキップ
    [ -e "$source_file" ] || continue

    filename=$(basename "$source_file")
    output_file="$RELEASE_DIR/$filename"

    echo "🔧 $filename を処理中..."

    # ファイルの内容を読み込み
    content=$(cat "$source_file")

    # プレースホルダーの置換処理
    needs_replacement=false

    # __DROPDOWN_DATA__ プレースホルダーの確認と置換
    if echo "$content" | grep -q "__DROPDOWN_DATA__"; then
        needs_replacement=true

        # GITHUB_REPOSITORIESからドロップダウンデータを生成
        DROPDOWN_DATA='{"title": "Home", "value": ""}'

        if [ -n "${GITHUB_REPOSITORIES:-}" ]; then
            # カンマ区切りのリポジトリをループ処理
            IFS=',' read -ra REPOS <<< "$GITHUB_REPOSITORIES"

            for repo in "${REPOS[@]}"; do
                # 前後の空白を削除
                repo=$(echo "$repo" | xargs)

                if [ -n "$repo" ]; then
                    # リポジトリ名から表示名を生成（owner/repo → repo）
                    display_name=$(echo "$repo" | cut -d'/' -f2)

                    # JSONデータを追加
                    DROPDOWN_DATA="$DROPDOWN_DATA, {\"title\": \"$display_name\", \"value\": \"$repo\"}"
                fi
            done
        fi

        # プレースホルダーを置換
        content=$(echo "$content" | sed "s|__DROPDOWN_DATA__|$DROPDOWN_DATA|g")

        echo "   ✓ GITHUB_REPOSITORIES からドロップダウンを生成しました"
    fi

    # __METALIFE_SPACE_ID__ プレースホルダーの確認と置換
    if echo "$content" | grep -q "__METALIFE_SPACE_ID__"; then
        needs_replacement=true

        if [ -n "${METALIFE_SPACE_ID:-}" ]; then
            # プレースホルダーを置換
            content=$(echo "$content" | sed "s|__METALIFE_SPACE_ID__|$METALIFE_SPACE_ID|g")
            echo "   ✓ METALIFE_SPACE_ID を埋め込みました"
        else
            echo "   ⚠️  警告: METALIFE_SPACE_ID が設定されていません"
        fi
    fi

    # __GOOGLE_ACCOUNT_INDEX__ プレースホルダーの確認と置換
    if echo "$content" | grep -q "__GOOGLE_ACCOUNT_INDEX__"; then
        needs_replacement=true

        # デフォルト値: 0
        ACCOUNT_INDEX="${GOOGLE_ACCOUNT_INDEX:-0}"

        # プレースホルダーを置換
        content=$(echo "$content" | sed "s|__GOOGLE_ACCOUNT_INDEX__|$ACCOUNT_INDEX|g")
        echo "   ✓ GOOGLE_ACCOUNT_INDEX を埋め込みました (値: $ACCOUNT_INDEX)"
    fi

    # ファイルを出力
    echo "$content" > "$output_file"

    # 実行権限を付与
    chmod +x "$output_file"

    processed_files=$((processed_files + 1))

    if [ "$needs_replacement" = true ]; then
        echo "   ✅ ビルド完了（環境変数から生成）"
    else
        echo "   ✅ コピー完了（変更なし）"
    fi
    echo ""
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 すべてのコマンドのビルドが完了しました！"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📊 処理結果:"
echo "   処理済み: $processed_files / $total_files ファイル"
echo "   出力先: $RELEASE_DIR"
echo ""
echo "📝 次のステップ:"
echo "   1. Raycast を開く"
echo "   2. Preferences → Extensions → Script Commands"
echo "   3. 'Add Directories' をクリック"
echo "   4. '$RELEASE_DIR' ディレクトリを選択"
echo ""
echo "💡 ヒント:"
echo "   - 環境変数を変更した場合は、このスクリプトを再実行してください"
echo "   - commands/release/ は Git で管理されません"
