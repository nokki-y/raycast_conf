#!/bin/bash

#############################################
# Okan Tasks 統合リリーススクリプト
#############################################
# 機能:
# - バージョン管理（セマンティックバージョニング）
# - デフォルト値の自動注入
# - Zipファイル自動生成
# - リリースノート生成
# - セキュリティチェック
#############################################

set -e

# 色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ディレクトリ設定
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
EXTENSION_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ROOT_DIR="$(cd "$EXTENSION_DIR/../.." && pwd)"
RELEASE_BASE_DIR="$EXTENSION_DIR/release"
VERSION_FILE="$EXTENSION_DIR/VERSION"

# 関数: ヘルプメッセージ
show_help() {
    cat << EOF
🚀 Okan Tasks リリーススクリプト

使い方:
  $0 [オプション] <バージョン>

バージョン:
  major               メジャーバージョンアップ (例: 1.0.0 → 2.0.0)
  minor               マイナーバージョンアップ (例: 1.0.0 → 1.1.0)
  patch               パッチバージョンアップ (例: 1.0.0 → 1.0.1)
  X.Y.Z               特定のバージョンを指定 (例: 1.2.3)

オプション:
  --dev               開発モードでビルド（1分間隔オプション有効）
  --no-tag            Gitタグを作成しない
  --no-cleanup        ビルド成果物を削除しない（デバッグ用）
  -h, --help          ヘルプを表示

例:
  $0 patch                    # パッチバージョンアップ
  $0 1.2.0                    # バージョン1.2.0でリリース
  $0 minor --no-tag           # タグなしでマイナーバージョンアップ
  $0 patch --dev              # 開発モードでパッチバージョンアップ

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

# 関数: 環境変数チェック
check_env() {
    info "環境変数をチェック中..."

    if [ ! -f "$EXTENSION_DIR/.env" ]; then
        error ".envファイルが見つかりません: $EXTENSION_DIR/.env"
    fi

    source "$EXTENSION_DIR/.env"

    if [ -z "$OKAN_SPREADSHEET_ID" ] || [ -z "$OKAN_SHEET_GID" ] || [ -z "$OKAN_SHEET_NAME" ]; then
        error ".envに必要な変数が設定されていません (OKAN_SPREADSHEET_ID, OKAN_SHEET_GID, OKAN_SHEET_NAME)"
    fi

    success "環境変数チェック完了"
}

# 関数: 認証情報チェック（削除済み - 配布用zipはローカルで別途作成）
# このスクリプトはGitHubリリース専用で、認証情報を含めません

# 関数: ビルド実行
build_extension() {
    local build_mode=$1

    if [ "$build_mode" = "development" ]; then
        info "拡張機能を開発モードでビルド中..."
        cd "$EXTENSION_DIR"
        npm run build:dev
    else
        info "拡張機能を本番モードでビルド中..."
        cd "$EXTENSION_DIR"
        npm run build
    fi

    success "ビルド完了"
}

# 関数: リリースパッケージ作成
create_release_package() {
    local version=$1
    local build_mode=$2
    local package_name="okan-tasks-v$version"

    # 開発モードの場合はrelease/devに、本番モードはrelease/v{version}に出力
    if [ "$build_mode" = "development" ]; then
        local release_dir="$RELEASE_BASE_DIR/dev"
        package_name="okan-tasks-v$version-dev"
    else
        local release_dir="$RELEASE_BASE_DIR/v$version"
    fi

    info "リリースパッケージを作成中..." >&2

    # クリーンアップ
    rm -rf "$release_dir"
    mkdir -p "$release_dir"

    # Raycastビルド済みディレクトリを確認
    local raycast_build_dir="$HOME/.config/raycast/extensions/raycast-okan"
    if [ ! -d "$raycast_build_dir" ]; then
        error "Raycastビルド出力が見つかりません: $raycast_build_dir"
    fi

    # ビルド済み拡張機能をコピー
    cp -r "$raycast_build_dir" "$release_dir/$package_name"

    # バージョンファイルを追加
    echo "$version" > "$release_dir/$package_name/VERSION"

    # インストールガイドを生成
    generate_install_guide "$release_dir/$package_name" "$version"

    # Zipファイルを作成
    info "Zipファイルを作成中..." >&2
    cd "$release_dir"
    zip -r "$package_name.zip" "$package_name" > /dev/null

    success "リリースパッケージ作成完了: $release_dir/$package_name.zip" >&2

    echo "$release_dir"
}

# 関数: インストールガイド生成
generate_install_guide() {
    local target_dir=$1
    local version=$2

    cat > "$target_dir/INSTALL.md" <<EOF
# おかんタスク確認 v$version - インストールガイド

## 📋 前提条件

- macOS
- Raycast がインストール済み
- Google認証情報（管理者から配布されたzipファイルに含まれています）

## 🚀 インストール手順

### ステップ1: 配布用Zipファイルを取得

**重要**: このGitHubリリースには認証情報が含まれていません。
実際にインストールするには、管理者から配布される**認証済みzipファイル**が必要です。

管理者から \`okan-tasks-v$version-dist.zip\` を取得してください。

### ステップ2: Zipファイルを解凍

1. 配布されたzipファイルを解凍
2. \`okan-tasks-v$version\` フォルダが作成されます
3. \`assets/.auth/\` ディレクトリに認証情報が含まれていることを確認

### ステップ3: Raycastにインポート

1. Raycast Preferences を開く (⌘ + ,)
2. **Extensions** タブを選択
3. 右上の **"+"** ボタンをクリック
4. **"Import Extension"** を選択
5. 解凍した \`okan-tasks-v$version\` フォルダを選択
6. インポート完了！

### ステップ3: 設定

1. Raycastを開く (⌘ + Space)
2. \`Check Okan Tasks\` と入力
3. 拡張機能の設定を開く (⌘ + K → Preferences)
4. 以下の項目を入力：

| 項目 | 説明 | デフォルト値 |
|------|------|-------------|
| **Spreadsheet ID** | スプレッドシートのID | 設定済み（変更不要） |
| **Sheet Name** | シート名 | 設定済み（変更不要） |
| **Sheet GID** | シートのGID | 設定済み（変更不要） |
| **My Name** | あなたの名前 | **要設定**（スプレッドシートの列ヘッダーと一致） |
| **通知間隔** | 通知を送る間隔 | 1時間（推奨） |

**重要**: **My Name** のみ必ず設定してください。スプレッドシートの列ヘッダー（担当者名）と完全一致させる必要があります。

### ステップ4: バックグラウンド通知を有効化（推奨）

デスクトップ通知を受け取りたい場合：

1. Raycast Preferences を開く (⌘ + ,)
2. **Extensions** → **Okan Tasks** → **Notify Okan Tasks** を探す
3. **Background Refresh** トグルを **ON** にする

これにより以下の通知が有効になります：
- 期日切れ・今日締切のタスクがあれば通知
- 通知間隔は設定で変更可能（デフォルト: 1時間）
- アラート形式（音なし、2ボタン方式）
  - **「OK」**: アラートを閉じる
  - **「タスクを確認」**: Raycastのタスク一覧を直接開く

### ステップ5: 動作確認

1. Raycastを開く (⌘ + Space)
2. \`Check Okan Tasks\` と入力
3. タスク一覧が表示されれば成功！

## ✨ 使い方

### 基本機能
- **期限切れ・2営業日以内のタスク**が自動的に表示されます
- タスクを選択して Enter → スプレッドシートの該当セルが開きます
- **完了**・**対象外**のタスクは自動的に除外されます
- アクセストークンは**自動的にリフレッシュ**されるため、メンテナンス不要

### 通知機能
- **デスクトップ通知**で期日切れタスクを見逃さない（Background Refresh有効時）
- **アラート形式**（音なし、2ボタン方式）
  - **「タスクを確認」**: Raycastのタスク一覧を直接開く
  - **「OK」**: アラートを閉じる

## ❓ トラブルシューティング

### 初期設定を間違えた・やり直したい

設定を変更する方法：

1. Raycastを開く (⌘ + Space)
2. \`Check Okan Tasks\` と入力
3. **⌘ + K** を押してアクションメニューを開く
4. **「Configure Extension」** を選択
5. 設定値を修正して保存

### タスクが表示されない

1. **My Name** がスプレッドシートの列ヘッダーと完全一致しているか確認
   - 大文字小文字、スペースに注意
   - スプレッドシートの1行目（列ヘッダー）と完全一致させる

### 通知が来ない

1. **Background Refresh** が有効になっているか確認
   - Raycast Preferences → Extensions → Notify Okan Tasks
   - トグルが **ON** になっているか確認

2. 通知の条件を確認
   - 期日切れまたは今日締切のタスクがある場合のみ通知されます

### その他の問題

管理者に連絡してください。

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
    local node_ver=$(node --version)
    local npm_ver=$(npm --version)

    info "リリースノートを生成中..."

    # ディレクトリが存在することを確認
    if [ ! -d "$release_dir" ]; then
        error "リリースディレクトリが存在しません: $release_dir"
    fi

    cat > "$release_dir/RELEASE_NOTES.md" <<EOF
# Okan Tasks v${version} リリースノート

**リリース日**: ${current_date}

## 📦 パッケージ内容

- \`okan-tasks-v${version}/\` - Raycast拡張機能
- \`INSTALL.md\` - インストールガイド
- \`VERSION\` - バージョン情報

## 🔐 セキュリティ

**このGitHubリリースには認証情報は含まれていません。**

エンドユーザー向けの配布には、別途管理者が作成する認証済みzipファイルが必要です。

## 📋 配布手順（管理者向け）

1. このリリース後、ローカルで \`npm run build:distribution\` を実行
2. 生成された \`okan-tasks-v${version}-dist.zip\` をGoogle Driveなどに配置
3. エンドユーザーに配布zipのURLを共有
4. 受け取った人は INSTALL.md に従ってインストール
5. **My Name** の設定を忘れずに（スプレッドシートの列ヘッダーと一致）

## 🎯 対象ユーザー

- 組織内のメンバー
- タスク管理スプレッドシートへのアクセス権がある人

## ⚙️ ビルド情報

- ビルド日時: ${current_date}
- Node.js: ${node_ver}
- npm: ${npm_ver}

## 📝 変更履歴

バージョンアップの詳細はGitコミット履歴を参照してください。

---

**連絡先**: 管理者に問い合わせてください
EOF

    success "リリースノート生成完了"
}

# 関数: Gitタグ作成
create_git_tag() {
    local version=$1
    local tag_name="okan-v$version"

    info "Gitタグを作成中..."

    cd "$ROOT_DIR"

    # バージョンファイルを更新
    echo "$version" > "$VERSION_FILE"
    git add "$VERSION_FILE"

    # コミット
    git commit -m "release(okan): v$version

🚀 Okan Tasks v$version をリリース

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"

    # タグ作成（拡張機能名をプレフィックスに）
    git tag -a "$tag_name" -m "Okan Tasks v$version"

    success "Gitタグ作成完了: $tag_name"

    info "リモートにプッシュするには以下を実行してください:"
    echo "  git push origin main"
    echo "  git push origin $tag_name"
}

# 関数: GitHub Release作成
create_github_release() {
    local version=$1
    local release_dir=$2
    local tag_name="okan-v$version"
    local zip_file="$release_dir/okan-tasks-v$version.zip"
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

    # GitHub Releaseを作成（zipファイルは含めない）
    info "GitHub Releaseを作成中..."
    gh release create "$tag_name" \
        --title "Okan Tasks v$version" \
        --notes-file "$notes_file"

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
CLEANUP=true
BUILD_MODE="production"

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        --dev)
            BUILD_MODE="development"
            shift
            ;;
        --no-tag)
            CREATE_TAG=false
            shift
            ;;
        --no-cleanup)
            CLEANUP=false
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
echo "  Okan Tasks リリース v$NEW_VERSION"
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

# チェック実行
check_env

# ビルド実行
build_extension "$BUILD_MODE"

# リリースパッケージ作成
RELEASE_DIR=$(create_release_package "$NEW_VERSION" "$BUILD_MODE")

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
echo "   $RELEASE_DIR/okan-tasks-v$NEW_VERSION.zip"
echo ""
info "📝 ドキュメント:"
echo "   - INSTALL.md: インストールガイド"
echo "   - RELEASE_NOTES.md: リリースノート"
echo ""

warn "重要: 配布先は信頼できる相手のみに限定してください"
echo ""
