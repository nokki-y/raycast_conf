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
- オプションで別のURLを指定可能
- 既存のタブがあれば自動的にアクティブにする（新規タブを開かない）
- 実行後、Raycastのコマンドウィンドウが自動的に閉じる

**セットアップ**:

1. `.env.example`を`.env`にコピー
2. `.env`ファイルに実際のスペースIDを設定

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
- Google Chrome（open_metalife.sh、open_x.sh使用時）

## 環境変数

秘匿情報は`.env`ファイルで管理されます（Gitには含まれません）。
`.env.example`を参考に`.env`ファイルを作成してください。
