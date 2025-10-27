# raycast_conf

Raycast用のカスタムスクリプトコレクション

## スクリプト一覧

### 🌐 open_metalife.sh

MetaLifeのスペースをChromeで開く

**使用方法**:

```text
Raycast → "Open MetaLife"
```

**機能**:

- 環境変数で管理されたスペースIDを使用
- `.env`ファイルから設定を読み込み
- 既存の同じMetaLifeタブがあれば自動的にアクティブにする（URL完全一致）
- 該当タブがない場合のみ新規タブで開く
- 実行後、Raycastのコマンドウィンドウが自動的に閉じる

**セットアップ**:

1. `.env.example`を`.env`にコピー
2. `.env`ファイルに実際のスペースIDを設定

### 📊 open_okan.sh

おかんスプレッドシートをChromeで開く

**使用方法**:

```text
Raycast → "Open おかん"
```

**機能**:

- 環境変数で管理されたスプレッドシートIDとシートGIDを使用
- `.env`ファイルから設定を読み込み
- 既存の同じスプレッドシートタブがあれば自動的にアクティブにする（URL完全一致）
- 該当タブがない場合のみ新規タブで開く
- 実行後、Raycastのコマンドウィンドウが自動的に閉じる

**セットアップ**:

1. `.env.example`を`.env`にコピー
2. `.env`ファイルに実際のスプレッドシートIDとシートGIDを設定

### 𝕏 open_x.sh

X（旧Twitter）のホームをChromeで開く

**使用方法**:

```text
Raycast → "Open X"
```

**機能**:

- X（https://x.com）のホームページを開く
- ドメイン一致で既存のXタブを検索してアクティブにする
  - 例: `/home`、`/messages`、`/notifications` など、どのXページでもアクティブになる
- Xのタブがない場合のみ新規タブで開く
- 実行後、Raycastのコマンドウィンドウが自動的に閉じる

### 📅 open_calendar.sh

GoogleカレンダーをChromeで開く

**使用方法**:

```text
Raycast → "Open Google Calendar"
```

**機能**:

- Googleカレンダーを開く
- ドメイン一致で既存のカレンダータブを検索してアクティブにする
- カレンダーのタブがない場合のみ新規タブで開く
- 環境変数でGoogleアカウントインデックスを指定可能（デフォルト: 0）
- 実行後、Raycastのコマンドウィンドウが自動的に閉じる

### 📧 open_mail.sh

GmailをChromeで開く

**使用方法**:

```text
Raycast → "Open Gmail"
```

**機能**:

- Gmailの受信トレイを開く
- ドメイン一致で既存のGmailタブを検索してアクティブにする
- Gmailのタブがない場合のみ新規タブで開く
- 環境変数でGoogleアカウントインデックスを指定可能（デフォルト: 0）
- 実行後、Raycastのコマンドウィンドウが自動的に閉じる

### 🐙 open_github.sh

GitHubをChromeで開く

**使用方法**:

```text
Raycast → "Open GitHub" → リポジトリを選択
  - nokki-y: nokki-yのプロフィール
  - lmi-mcs/survey-hub: survey-hubリポジトリ
```

**機能**:

- ドロップダウンから開きたいページを選択
- **nokki-y選択時**: nokki-yのプロフィールを開く（ドメイン一致で既存のGitHubタブを検索）
- **リポジトリ選択時**: 指定したリポジトリを開く（完全一致で既存タブを検索）
- 該当タブがない場合のみ新規タブで開く
- 実行後、Raycastのコマンドウィンドウが自動的に閉じる

### 📹 activate_meet.sh

開いているGoogle Meetタブをアクティブにする

**使用方法**:

```text
Raycast → "Activate Google Meet"
```

**機能**:

- Chromeで開いているGoogle Meetタブを検索
- 見つかった場合、そのタブをアクティブにする
- タブが見つからない場合は警告メッセージを表示
- 実行後、Raycastのコマンドウィンドウが自動的に閉じる

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
- 重複起動防止機能付き

### ⏰ prevent_sleep_timer.sh

指定時間だけスクリーンセーバーとスリープを防止する

**使用方法**:

```text
Raycast → "Prevent Sleep Timer" → 分数を入力（例: 30, 60, 120）
```

**機能**:

- 指定した分数だけスリープを防止
- 終了予定時刻を表示
- 自動的に終了

## セットアップ

1. このリポジトリをクローン
2. 環境変数ファイルを設定（必要に応じて）

   ```bash
   cp .env.example .env
   # .env ファイルを編集して実際の値を設定
   ```

3. Raycastの設定でスクリプトディレクトリとして指定
4. スクリプトが自動的にRaycastに認識される

## 必要な環境

- macOS
- Raycast
- Bash
- Google Chrome（open_metalife.sh、open_okan.sh、open_x.sh、open_calendar.sh、open_mail.sh、open_github.sh、activate_meet.sh使用時）

## 環境変数

秘匿情報は`.env`ファイルで管理されます（Gitには含まれません）。
`.env.example`を参考に`.env`ファイルを作成してください。
