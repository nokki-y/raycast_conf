# Raycast Script Commands

このディレクトリには、Raycastで使用するシェルスクリプトコマンドが含まれています。

## 🚀 スクリプト一覧

### 🌐 open_metalife.sh
MetaLifeのスペースをChromeで開く

**使用方法**: `Raycast → "Open MetaLife"`

**機能**:
- 環境変数で管理されたスペースIDを使用
- 既存タブがあれば自動的にアクティブにする
- 該当タブがない場合のみ新規タブで開く

---

### 𝕏 open_x.sh
X(旧Twitter)のホームをChromeで開く

**使用方法**: `Raycast → "Open X"`

**機能**:
- ドメイン一致で既存のXタブを検索してアクティブにする
- Xのタブがない場合のみ新規タブで開く

---

### 📅 open_calendar.sh
GoogleカレンダーをChromeで開く

**使用方法**: `Raycast → "Open Google Calendar"`

**機能**:
- ドメイン一致で既存のカレンダータブを検索してアクティブにする
- 環境変数でGoogleアカウントインデックスを指定可能

---

### 📧 open_mail.sh
GmailをChromeで開く

**使用方法**: `Raycast → "Open Gmail"`

**機能**:
- ドメイン一致で既存のGmailタブを検索してアクティブにする
- 環境変数でGoogleアカウントインデックスを指定可能

---

### 🐙 open_github.sh
GitHubをChromeで開く

**使用方法**: `Raycast → "Open GitHub" → リポジトリを選択`

**機能**:
- ドロップダウンから開きたいページを選択
- URLプレフィックス一致で既存タブを検索してアクティブにする
- 該当タブがない場合のみ新規タブで開く

---

### 📹 activate_meet.sh
開いているGoogle Meetタブをアクティブにする

**使用方法**: `Raycast → "Activate Google Meet"`

**機能**:
- Chromeで開いているGoogle Meetタブを検索
- 見つかった場合、そのタブをアクティブにする

---

### ☕ prevent_sleep.sh
スクリーンセーバーとスリープを防止する

**使用方法**:
- 開始: `Raycast → "Prevent Sleep" → Start`
- 停止: `Raycast → "Prevent Sleep" → Stop`
- 状態確認: `Raycast → "Prevent Sleep" → Status`

**機能**:
- macOS標準の`caffeinate`コマンドを使用
- ディスプレイのスリープとシステムスリープを防止
- バックグラウンドで動作

---

### ⏰ prevent_sleep_timer.sh
指定時間だけスクリーンセーバーとスリープを防止する

**使用方法**: `Raycast → "Prevent Sleep Timer" → 分数を入力`

**機能**:
- 指定した分数だけスリープを防止
- 終了予定時刻を表示
- 自動的に終了

---

## 📝 セットアップ

### 1. 環境変数の設定
プロジェクトルートの `.env` ファイルに必要な環境変数を設定してください。

```bash
# MetaLife
METALIFE_SPACE_ID=your_space_id_here

# Google アカウント
GOOGLE_ACCOUNT_INDEX=0
```

詳細は [../.env.example](../.env.example) を参照してください。

### 2. Raycastへの登録

1. Raycast Preferences を開く
2. Extensions → Script Commands をクリック
3. 「Add Directories」をクリック
4. このディレクトリ(`scripts/`)を選択

スクリプトが自動的にRaycastに認識されます。

---

## 💻 必要な環境

- macOS
- Raycast
- Bash
- Google Chrome (ブラウザ操作系スクリプト使用時)

---

## 📄 スクリプトの仕様

各スクリプトは以下の共通仕様に従っています:

- **環境変数**: プロジェクトルートの `.env` ファイルから読み込み
- **既存タブ検索**: 同じURLのタブがあれば、新規タブを開かずにアクティブ化
- **エラーハンドリング**: 必要な環境変数が設定されていない場合はエラーメッセージを表示
- **Raycastメタデータ**: 各スクリプトのヘッダーにRaycast用のメタデータを記載

---

プロジェクト全体の情報は [../README.md](../README.md) を参照してください。
