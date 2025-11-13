#!/bin/bash

#############################################
# Raycast Commands 統合リリーススクリプト
#############################################
# 機能:
# - バージョン管理（セマンティックバージョニング）
# - ビルド実行
# - Zipファイル自動生成
# - リリースノート生成
# - Gitタグ作成
# - GitHub Release自動作成
#############################################

set -e

# 色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ディレクトリ設定
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMANDS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="$(cd "$COMMANDS_DIR/.." && pwd)"
RELEASE_BASE_DIR="$COMMANDS_DIR/release-packages"
VERSION_FILE="$COMMANDS_DIR/VERSION"

# 関数: ヘルプメッセージ
show_help() {
    cat << EOF
🚀 Raycast Commands リリーススクリプト

使い方:
  $0 [オプション] <バージョン>

バージョン:
  major               メジャーバージョンアップ (例: 1.0.0 → 2.0.0)
  minor               マイナーバージョンアップ (例: 1.0.0 → 1.1.0)
  patch               パッチバージョンアップ (例: 1.0.0 → 1.0.1)
  X.Y.Z               特定のバージョンを指定 (例: 1.2.3)

オプション:
  --no-tag            Gitタグを作成しない
  -h, --help          ヘルプを表示

例:
  $0 patch                    # パッチバージョンアップ
  $0 1.0.0                    # バージョン1.0.0でリリース
  $0 minor --no-tag           # タグなしでマイナーバージョンアップ

EOF
}

# 関数: エラーメッセージ
error() {
    echo -e "${RED}❌ エラー: $1${NC}" >&2
    exit 1
}

# 関数: 警告メッセージ
warn() {
    echo -e "${YELLOW}⚠️  警告: $1${NC}"
}

# 関数: 成功メッセージ
success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# 関数: 情報メッセージ
info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# 関数: 現在のバージョンを取得
get_current_version() {
    if [ -f "$VERSION_FILE" ]; then
        cat "$VERSION_FILE"
    else
        echo "0.0.0"
    fi
}

# 関数: バージョン番号をインクリメント
increment_version() {
    local version=$1
    local type=$2

    IFS='.' read -r -a parts <<< "$version"
    local major="${parts[0]}"
    local minor="${parts[1]}"
    local patch="${parts[2]}"

    case $type in
        major)
            echo "$((major + 1)).0.0"
            ;;
        minor)
            echo "${major}.$((minor + 1)).0"
            ;;
        patch)
            echo "${major}.${minor}.$((patch + 1))"
            ;;
        *)
            error "不明なバージョンタイプ: $type"
            ;;
    esac
}

# 関数: バージョン番号の検証
validate_version() {
    local version=$1
    if ! [[ $version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        error "無効なバージョン形式: $version (X.Y.Z形式で指定してください)"
    fi
}

# 関数: ビルド実行
build_commands() {
    info "コマンドをビルド中..."
    cd "$COMMANDS_DIR"
    bash scripts/build.sh
    success "ビルド完了"
}

# 関数: リリースパッケージ作成
create_release_package() {
    local version=$1
    local package_name="raycast-commands-v$version"
    local release_dir="$RELEASE_BASE_DIR/v$version"

    info "リリースパッケージを作成中..." >&2

    # クリーンアップ
    rm -rf "$release_dir"
    mkdir -p "$release_dir"

    # ビルド済みコマンドをコピー
    cp -r "$COMMANDS_DIR/release" "$release_dir/$package_name"

    # バージョンファイルを追加
    echo "$version" > "$release_dir/$package_name/VERSION"

    # READMEを生成
    generate_readme "$release_dir/$package_name" "$version"

    # Zipファイルを作成
    info "Zipファイルを作成中..." >&2
    cd "$release_dir"
    zip -r "$package_name.zip" "$package_name" > /dev/null

    success "リリースパッケージ作成完了: $release_dir/$package_name.zip" >&2

    echo "$release_dir"
}

# 関数: README生成
generate_readme() {
    local target_dir=$1
    local version=$2

    cat > "$target_dir/README.md" <<EOF
# Raycast Commands v$version

## 📋 インストール手順

1. **Raycast Preferences を開く**
   - ⌘ + , を押す

2. **Script Commands を追加**
   - Extensions → Script Commands
   - 右下の "+" ボタンをクリック
   - "Add Directories" を選択
   - この \`raycast-commands-v$version\` フォルダを選択

3. **完了！**
   - Raycastでコマンド名を検索して実行できます

## 📦 含まれるコマンド

- **Open MetaLife** - MetaLifeスペースを開く
- **Open GitHub** - GitHubリポジトリを開く
- **Open Google Calendar** - Googleカレンダーを開く
- **Open Gmail** - Gmailを開く
- その他のユーティリティコマンド

## 🔄 更新方法

新しいバージョンがリリースされたら：

1. 新しいZipファイルをダウンロード
2. 解凍
3. Raycast Preferencesで古いディレクトリを削除
4. 新しいディレクトリを追加

---

**バージョン**: v$version
**リリース日**: $(date +"%Y-%m-%d")
EOF
}

# 関数: リリースノート生成
generate_release_notes() {
    local version=$1
    local release_dir=$2
    local current_date=$(date +"%Y-%m-%d %H:%M:%S")

    info "リリースノートを生成中..." >&2

    # ディレクトリが存在することを確認
    if [ ! -d "$release_dir" ]; then
        error "リリースディレクトリが存在しません: $release_dir"
    fi

    cat > "$release_dir/RELEASE_NOTES.md" <<EOF
# Raycast Commands v${version} リリースノート

**リリース日**: ${current_date}

## 📦 パッケージ内容

- \`raycast-commands-v${version}/\` - ビルド済みRaycastコマンド
- \`README.md\` - インストールガイド
- \`VERSION\` - バージョン情報

## 🚀 インストール

1. \`raycast-commands-v${version}.zip\` を解凍
2. Raycast Preferences → Extensions → Script Commands
3. "Add Directories" で解凍したフォルダを選択

## 📝 含まれるコマンド

- Open MetaLife
- Open GitHub
- Open Google Calendar
- Open Gmail
- Activate Google Meet
- Open X (Twitter)
- Prevent Sleep
- Prevent Sleep Timer

## 📋 変更履歴

バージョンアップの詳細はGitコミット履歴を参照してください。

---

**連絡先**: 管理者に問い合わせてください
EOF

    success "リリースノート生成完了" >&2
}

# 関数: Gitタグ作成
create_git_tag() {
    local version=$1
    local tag_name="commands-v$version"

    info "Gitタグを作成中..."

    cd "$PROJECT_ROOT"

    # バージョンファイルを更新
    echo "$version" > "$VERSION_FILE"
    git add "$VERSION_FILE"

    # コミット
    git commit -m "release(commands): v$version

🚀 Raycast Commands v$version をリリース

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"

    # タグ作成
    git tag -a "$tag_name" -m "Raycast Commands v$version"

    success "Gitタグ作成完了: $tag_name"

    info "リモートにプッシュするには以下を実行してください:"
    echo "  git push origin main"
    echo "  git push origin $tag_name"
}

# 関数: GitHub Release作成
create_github_release() {
    local version=$1
    local release_dir=$2
    local tag_name="commands-v$version"
    local zip_file="$release_dir/raycast-commands-v$version.zip"
    local notes_file="$release_dir/RELEASE_NOTES.md"

    info "GitHub Releaseを作成中..."

    # gh CLIがインストールされているか確認
    if ! command -v gh &> /dev/null; then
        warn "gh CLI がインストールされていません"
        warn "GitHub Releaseは手動で作成してください"
        return 0
    fi

    # リモートにプッシュ
    info "リモートにプッシュ中..."
    git push origin main
    git push origin "$tag_name"

    # GitHub Releaseを作成
    info "GitHub Releaseを作成中..."
    gh release create "$tag_name" \
        --title "Raycast Commands v$version" \
        --notes-file "$notes_file" \
        "$zip_file"

    if [ $? -eq 0 ]; then
        success "GitHub Release作成完了: https://github.com/$(gh repo view --json nameWithOwner -q .nameWithOwner)/releases/tag/$tag_name"
    else
        warn "GitHub Release作成に失敗しました"
        warn "手動で作成してください"
    fi
}

#############################################
# メイン処理
#############################################

# オプション解析
CREATE_TAG=true

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        --no-tag)
            CREATE_TAG=false
            shift
            ;;
        *)
            VERSION_ARG=$1
            shift
            ;;
    esac
done

# バージョン引数チェック
if [ -z "$VERSION_ARG" ]; then
    error "バージョンを指定してください。使い方: $0 [major|minor|patch|X.Y.Z]"
fi

# バージョン計算
CURRENT_VERSION=$(get_current_version)
info "現在のバージョン: $CURRENT_VERSION"

case $VERSION_ARG in
    major|minor|patch)
        NEW_VERSION=$(increment_version "$CURRENT_VERSION" "$VERSION_ARG")
        ;;
    *)
        NEW_VERSION=$VERSION_ARG
        validate_version "$NEW_VERSION"
        ;;
esac

info "新しいバージョン: $NEW_VERSION"

# 確認
echo ""
echo "========================================"
echo "  Raycast Commands リリース v$NEW_VERSION"
echo "========================================"
echo ""
read -p "続行しますか？ (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "キャンセルしました"
    exit 0
fi

echo ""
echo "🚀 リリースを開始します..."
echo ""

# ビルド実行
build_commands

# リリースパッケージ作成
RELEASE_DIR=$(create_release_package "$NEW_VERSION")

# リリースノート生成
generate_release_notes "$NEW_VERSION" "$RELEASE_DIR"

# Gitタグ作成とGitHub Release作成
if [ "$CREATE_TAG" = true ]; then
    create_git_tag "$NEW_VERSION"
    create_github_release "$NEW_VERSION" "$RELEASE_DIR"
fi

# 完了メッセージ
echo ""
echo "========================================"
success "リリース完了: v$NEW_VERSION"
echo "========================================"
echo ""
info "📁 リリースディレクトリ:"
echo "   $RELEASE_DIR"
echo ""
info "📦 配布ファイル:"
echo "   $RELEASE_DIR/raycast-commands-v$NEW_VERSION.zip"
echo ""
info "📝 ドキュメント:"
echo "   - README.md: インストールガイド"
echo "   - RELEASE_NOTES.md: リリースノート"
echo ""

warn "重要: 配布先は信頼できる相手のみに限定してください"
echo ""
