#!/bin/bash

# リリース用パッケージをビルドするスクリプト

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR/.."
RELEASE_DIR="$PROJECT_DIR/release"
RELEASE_NAME="okan-tasks-raycast"

echo "🔨 リリースパッケージをビルドしています..."

# クリーンアップ
rm -rf "$RELEASE_DIR"
mkdir -p "$RELEASE_DIR"

# プロダクションビルド
echo "📦 拡張機能をビルド中..."
cd "$PROJECT_DIR"
npm run build

# Raycastビルド済みディレクトリをベースにする
RAYCAST_BUILD_DIR="$HOME/.config/raycast/extensions/raycast-okan"
if [ ! -d "$RAYCAST_BUILD_DIR" ]; then
    echo "❌ エラー: Raycastビルド出力が見つかりません: $RAYCAST_BUILD_DIR"
    echo "   拡張機能を一度ビルドしてください"
    exit 1
fi

echo "📋 ビルド済み拡張機能をコピー中..."
mkdir -p "$RELEASE_DIR"
cp -r "$RAYCAST_BUILD_DIR" "$RELEASE_DIR/$RELEASE_NAME"

# .authディレクトリをコピー（認証済みの状態で配布）
echo "🔐 認証情報をコピー中..."
if [ -d "$PROJECT_DIR/assets/.auth" ] && [ -f "$PROJECT_DIR/assets/.auth/token.json" ]; then
    # ビルド済みディレクトリ内のassetsに.authを上書き
    mkdir -p "$RELEASE_DIR/$RELEASE_NAME/assets"
    cp -r "$PROJECT_DIR/assets/.auth" "$RELEASE_DIR/$RELEASE_NAME/assets/"
    echo "✅ 認証情報をコピーしました（エンドユーザーは認証不要）"
else
    echo "⚠️  警告: assets/.auth/token.json が見つかりません"
    echo "   npm run setup-auth を先に実行してください"
    exit 1
fi

# ユーザー向けガイドを作成
cat > "$RELEASE_DIR/$RELEASE_NAME/INSTALL.md" <<'EOF'
# おかんタスク確認 - インストールガイド

## 📋 前提条件

- macOS
- Raycast がインストール済み

## 🚀 インストール手順

### ステップ1: Zipファイルを解凍

1. `okan-tasks-raycast.zip` を解凍
2. `okan-tasks-raycast` フォルダが作成されます

**注意**: 認証情報は既に含まれているため、認証作業は不要です！

### ステップ2: Raycastにインポート

1. Raycast Preferences を開く (⌘ + ,)
2. **Extensions** タブを選択
3. 右上の **"+"** ボタンをクリック
4. **"Import Extension"** を選択
5. 解凍した `okan-tasks-raycast` フォルダを選択
6. インポート完了！

### ステップ3: 設定

1. Raycastを開く (⌘ + Space)
2. `Check Okan Tasks` と入力
3. 拡張機能の設定を開く (⌘ + K → Preferences)
4. 以下の項目を入力：

| 項目 | 説明 | 取得方法 |
|------|------|---------|
| **Spreadsheet ID** | スプレッドシートのID | URLから: `https://docs.google.com/spreadsheets/d/{ここ}/` |
| **Sheet Name** | シート名 | 例: `【Todo】タスク一覧` |
| **Sheet GID** | シートのGID | URLから: `?gid={ここ}` |
| **My Name** | あなたの名前 | スプレッドシートの列ヘッダーと完全一致 |
| **チェック頻度** | タスクをチェックする頻度 | デフォルト: 1時間（推奨） |
| **通知間隔** | 実際に通知を送る間隔 | デフォルト: 1時間（推奨） |

### ステップ4: バックグラウンド通知を有効化（推奨）

デスクトップ通知を受け取りたい場合：

1. Raycast Preferences を開く (⌘ + ,)
2. **Extensions** → **Okan Tasks** → **Notify Okan Tasks** を探す
3. **Background Refresh** トグルを **ON** にする

これにより以下の通知が有効になります：
- 平日10-18時：期日切れ・今日締切のタスク通知
- チェック頻度と通知間隔は設定で変更可能（デフォルト: 1時間）

**設定のポイント**：
- **チェック頻度**: Raycastがタスクをチェックする頻度（15分/30分/1時間/2時間）
- **通知間隔**: 実際に通知を送る間隔（15分/30分/1時間/2時間/4時間）
- 例: チェック頻度1時間、通知間隔2時間 → 1時間ごとにチェックするが、通知は2時間ごと
- **Raycast再起動時**: 自動的にタイマーがリセットされ、すぐに通知が来ます

### ステップ5: 動作確認

1. Raycastを開く (⌘ + Space)
2. `Check Okan Tasks` と入力
3. タスク一覧が表示されれば成功！

## ✨ 使い方

- **期限切れ・2営業日以内のタスク**が自動的に表示されます
- タスクを選択して Enter → スプレッドシートの該当セルが開きます
- **完了**・**対象外**のタスクは自動的に除外されます
- アクセストークンは**自動的にリフレッシュ**されるため、メンテナンス不要
- **デスクトップ通知**で期日切れタスクを見逃さない（Background Refresh有効時）

## ❓ トラブルシューティング

### 初期設定を間違えた・やり直したい

設定を変更する方法：

1. Raycastを開く (⌘ + Space)
2. `Check Okan Tasks` と入力
3. **⌘ + K** を押してアクションメニューを開く
4. **「Configure Extension」** を選択
5. 設定値を修正して保存

または、完全にやり直したい場合：

1. Raycast Preferences (⌘ + ,) → Extensions
2. **Okan Tasks** を右クリック → **Uninstall**
3. 再度インポートして設定を入力し直す

### タスクが表示されない

1. Spreadsheet ID が正しいか確認
2. Sheet Name が正しいか確認（大文字小文字、スペースに注意）
3. My Name がスプレッドシートの列ヘッダーと完全一致しているか確認

**確認方法**：
- スプレッドシートのURLから正しいIDとGIDをコピー
- シート名はスプレッドシートのタブ名と完全一致させる
- 名前はスプレッドシートの列ヘッダー（1行目）と完全一致させる

### 通知が来ない

1. **Background Refresh** が有効になっているか確認
   - Raycast Preferences → Extensions → Notify Okan Tasks
   - トグルが **ON** になっているか確認

2. 通知の条件を確認
   - 平日10-18時：期日切れまたは今日締切のタスクがある場合のみ
   - 設定した間隔で通知（デフォルト: 1時間ごと）
   - 土日は通知なし

3. チェック頻度・通知間隔を確認・変更
   - Raycast → Check Okan Tasks → ⌘ + K → Configure Extension
   - 「チェック頻度」: タスクをチェックする頻度（15分/30分/1時間/2時間）
   - 「通知間隔」: 実際に通知を送る間隔（15分/30分/1時間/2時間/4時間）
   - 推奨設定: チェック頻度1時間、通知間隔1時間

### 401 Unauthorized エラーが出る

通常は自動リフレッシュされますが、もしエラーが出た場合は管理者に連絡してください。

### その他の問題

管理者に連絡してください。
EOF

echo ""
echo "✅ リリースパッケージの作成が完了しました！"
echo ""
echo "📁 パッケージの場所: $RELEASE_DIR/$RELEASE_NAME"
echo ""
echo "📤 配布方法:"
echo "1. Zipファイルを作成:"
echo "   cd $RELEASE_DIR && zip -r okan-tasks-raycast.zip okan-tasks-raycast/"
echo ""
echo "2. okan-tasks-raycast.zip を配布"
echo ""
echo "3. 受け取った人の作業:"
echo "   - Zipを解凍"
echo "   - Raycast Preferences → Extensions → + → Import Extension"
echo "   - okan-tasks-raycast フォルダを選択"
echo "   - 設定（Spreadsheet ID, Sheet Name, My Name など）を入力"
echo ""
echo "⚠️  重要: 認証情報が含まれているため、配布先は信頼できる相手のみに限定してください"
echo ""
