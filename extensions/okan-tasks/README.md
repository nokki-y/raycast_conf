# おかんタスク確認 Raycast Extension セットアップ手順

このドキュメントでは、おかんスプレッドシートの未完了タスクをRaycastで確認できる拡張機能のセットアップ方法を説明します。

## 前提条件

- Node.js (v16以上)
- Raycast がインストール済み
- Google Cloud Console へのアクセス権限

## 1. Google Cloud Console の設定

### 1.1 プロジェクトの作成

1. [Google Cloud Console](https://console.cloud.google.com/) にアクセス
2. 新しいプロジェクトを作成 (例: `raycast-okan`)

### 1.2 Google Sheets API の有効化

1. 「APIとサービス」→「ライブラリ」をクリック
2. 「Google Sheets API」を検索
3. 「有効にする」をクリック

### 1.3 OAuth 2.0 認証情報の作成

1. 「APIとサービス」→「認証情報」をクリック
2. 「認証情報を作成」→「OAuthクライアントID」を選択
3. 同意画面の設定を求められたら、以下を設定:
   - ユーザータイプ: 外部
   - アプリ名: 任意 (例: Raycast Okan)
   - サポートメール: あなたのメールアドレス
   - スコープは追加不要
   - テストユーザー: あなたのGoogleアカウントを追加
4. アプリケーションの種類: **デスクトップアプリ**
5. 名前: 任意 (例: raycast-okan-client)
6. 「作成」をクリック

### 1.4 認証情報のダウンロード

1. 作成した認証情報の右側にあるダウンロードアイコン(↓)をクリック
2. JSONファイルがダウンロードされます

## 2. 認証情報の配置

ダウンロードしたJSONファイルを拡張機能ディレクトリ内に配置します:

```bash
# ダウンロードしたJSONファイルを移動してリネーム
mv ~/Downloads/client_secret_*.json extensions/okan-tasks/.auth/credentials.json
```

**注意**: `.auth/` ディレクトリ内のファイルはGitで管理されません(秘匿情報のため)。

## 3. 環境変数の設定

### 3.1 .env ファイルの編集

プロジェクトルートの `.env` ファイルに以下を追加/編集します:

```bash
# おかんスプレッドシートID
OKAN_SPREADSHEET_ID=your_spreadsheet_id_here

# シートGID (URLのgid=の後の数字)
OKAN_SHEET_GID=0

# シート名
OKAN_SHEET_NAME=【Todo】PD室タスク一覧

# あなたの名前 (スプレッドシートの列ヘッダーと完全一致させること)
OKAN_MY_NAME=鵜木 義秀
```

### 3.2 スプレッドシートIDの確認方法

スプレッドシートのURLから取得します:

```
https://docs.google.com/spreadsheets/d/{SPREADSHEET_ID}/edit?gid={GID}
                                        ^^^^^^^^^^^^^^^^         ^^^
```

## 4. 初回認証

以下のコマンドで初回認証を実行します:

```bash
npm run setup-auth
```

### 認証の流れ

1. ブラウザでURLが表示されます
2. URLをブラウザで開く
3. Googleアカウントでログイン
4. アクセス許可を承認
5. 表示される認証コードをコピー
6. ターミナルに認証コードを貼り付けて Enter

成功すると、`~/.config/raycast-okan/token.json` にトークンが保存されます。

## 5. Raycast への登録

### 5.1 開発モードで実行

```bash
npm run dev
```

これにより、Raycastに拡張機能が自動的に追加されます。

### 5.2 使い方

1. Raycastを起動 (⌘ + Space)
2. `Check Okan Tasks` と入力
3. 未完了タスクの一覧が表示されます
4. タスクを選択して Enter を押すと、該当行のスプレッドシートが開きます

### 5.3 キーボードショートカット

- `Enter`: スプレッドシートで開く
- `⌘ + C`: タスク名をコピー
- `⌘ + Shift + C`: URLをコピー

## トラブルシューティング

### エラー: 認証情報ファイルが見つかりません

`extensions/okan-tasks/.auth/credentials.json` が正しく配置されているか確認してください。

### エラー: スプレッドシートに「鵜木 義秀」の列が見つかりません

- `.env` ファイルの `OKAN_MY_NAME` がスプレッドシートの列ヘッダーと完全一致しているか確認
- 空白文字や全角/半角に注意

### エラー: 認証トークンが見つかりません

`npm run setup-auth` を実行して、初回認証を完了させてください。

### タスクが表示されない

1. スプレッドシートIDが正しいか確認
2. シート名が正しいか確認
3. あなたの列に「完了」「対象外」以外の値(空欄含む)があるか確認

## ファイル構成

```
raycast_conf/
├── src/
│   ├── check-okan-tasks.tsx    # メインのRaycastコマンド
│   ├── okan-service.ts         # スプレッドシート取得ロジック
│   ├── google-auth.ts          # Google認証ヘルパー
│   └── setup-auth.ts           # 初回認証スクリプト
├── assets/
│   └── icon.png                # 拡張機能のアイコン
├── package.json
├── tsconfig.json
└── .env                        # 環境変数設定
```

## 注意事項

- 認証トークン(`token.json`)は機密情報です。共有しないでください
- 認証情報(`credentials.json`)も機密情報です。Gitにコミットしないでください
- トークンの有効期限が切れた場合は、`npm run setup-auth` を再実行してください
