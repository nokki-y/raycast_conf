# おかんタスク確認 Raycast Extension

おかんスプレッドシートから期限が迫っているタスクをRaycastで素早く確認できる拡張機能です。

## 機能

- ✅ **期限フィルタリング**: 期限切れ + 2営業日以内のタスクのみ表示
- ✅ **ステータス自動判定**: 「完了」「対象外」を自動除外
- ✅ **直接編集**: タスクをクリックして該当セルで直接スプレッドシートを開く
- ✅ **軽量実装**: Google Sheets REST APIで高速動作

## 前提条件

- Node.js (v16以上)
- Raycast がインストール済み
- Google Cloud Console へのアクセス権限

## セットアップ

### 1. Google Cloud Console の設定

#### 1.1 プロジェクトの作成

1. [Google Cloud Console](https://console.cloud.google.com/) にアクセス
2. 新しいプロジェクトを作成 (例: `raycast-okan`)

#### 1.2 Google Sheets API の有効化

1. 「APIとサービス」→「ライブラリ」をクリック
2. 「Google Sheets API」を検索
3. 「有効にする」をクリック

#### 1.3 OAuth 2.0 認証情報の作成

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

#### 1.4 認証情報のダウンロード

1. 作成した認証情報の右側にあるダウンロードアイコン(↓)をクリック
2. JSONファイルがダウンロードされます
3. ファイルを `extensions/okan-tasks/.auth/credentials.json` に配置

```bash
# ダウンロードしたJSONファイルを移動してリネーム
mv ~/Downloads/client_secret_*.json extensions/okan-tasks/.auth/credentials.json
```

**注意**: `.auth/` ディレクトリ内のファイルはGitで管理されません(秘匿情報のため)。

### 2. 初回認証とトークン取得

#### 2.1 OAuth認証フローを実行

認証スクリプトを実行して、初回のOAuth認証を行います：

```bash
cd extensions/okan-tasks
npm install
npm run setup-auth
```

#### 2.2 認証の流れ

1. ブラウザでURLが表示されます
2. URLをブラウザで開く
3. Googleアカウントでログイン
4. アクセス許可を承認
5. 表示される認証コードをコピー
6. ターミナルに認証コードを貼り付けて Enter

成功すると、`extensions/okan-tasks/.auth/token.json` にアクセストークンとリフレッシュトークンが保存されます。

#### 2.3 アクセストークンの取得

`token.json` から `access_token` をコピーして、`src/sheets-api.ts` の `ACCESS_TOKEN` に貼り付けます：

```typescript
// src/sheets-api.ts
const ACCESS_TOKEN = "ya29.a0..."; // ここに貼り付け
```

**注意**: アクセストークンは約1時間で期限切れになります。期限切れの場合は、以下のコマンドで更新できます：

```bash
curl -X POST https://oauth2.googleapis.com/token \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "client_id=YOUR_CLIENT_ID" \
  -d "client_secret=YOUR_CLIENT_SECRET" \
  -d "refresh_token=YOUR_REFRESH_TOKEN" \
  -d "grant_type=refresh_token"
```

### 3. Raycast Preferences の設定

Raycastで拡張機能を開き、以下の設定を行います：

1. **Spreadsheet ID**: スプレッドシートのID
   - URLの `https://docs.google.com/spreadsheets/d/{SPREADSHEET_ID}/edit` から取得
2. **Sheet Name**: シート名（例: `【Todo】PD室タスク一覧`）
3. **Sheet GID**: シートのGID
   - URLの `?gid={GID}` から取得
4. **My Name**: あなたの名前（例: `鵜木 義秀`）
   - スプレッドシートの列ヘッダーと完全一致させること

### 4. Raycast への登録

#### 4.1 開発モードで実行

```bash
cd extensions/okan-tasks
npm run dev
```

これにより、Raycastに拡張機能が自動的に追加されます。

#### 4.2 使い方

1. Raycastを起動 (⌘ + Space)
2. `Check Okan Tasks` と入力
3. **期限切れ・2営業日以内の未完了タスク**の一覧が表示されます
4. タスクを選択して Enter を押すと、**あなたのステータスセル**が選択された状態でスプレッドシートが開きます

### 4.3 表示されるタスク

以下の条件をすべて満たすタスクのみが表示されます：

- ✅ あなたの列（例: CI列）のステータスが「完了」「対象外」以外
- ✅ 期日が**期限切れ** または **2営業日以内**
- ✅ タスクタイトルが存在する

**営業日の計算**: 土日を除いた営業日で計算されます。
- 例: 今日が金曜日 → 2営業日後は火曜日

## トラブルシューティング

### エラー: 401 Unauthorized

アクセストークンの期限が切れています。リフレッシュトークンを使って新しいアクセストークンを取得し、`src/sheets-api.ts` を更新してください。

### エラー: 自分の列が見つかりません

- Raycast Preferencesの `My Name` がスプレッドシートの列ヘッダーと完全一致しているか確認
- 空白文字や全角/半角に注意
- スプレッドシートに107列以上のデータがあるか確認（あなたの列がCI列 = 87列目の場合）

### タスクが表示されない

1. スプレッドシートIDが正しいか確認
2. シート名が正しいか確認（`【Todo】PD室タスク一覧`）
3. あなたの列に「完了」「対象外」以外の値があるか確認（空欄も表示対象）
4. タスクの期日が**期限切れまたは2営業日以内**か確認

### タスクはあるのに0件と表示される

- 期日が3営業日以降のタスクは表示されません
- 期日の形式が `M/D` 形式（例: `10/28`, `11/4`）であることを確認

## ファイル構成

```
extensions/okan-tasks/
├── src/
│   ├── check-okan-tasks.tsx    # メインのRaycastコマンド
│   └── sheets-api.ts            # Google Sheets REST API呼び出し
├── .auth/                       # 認証情報（Gitで管理しない）
│   ├── credentials.json         # OAuth クライアント情報
│   └── token.json               # アクセストークン・リフレッシュトークン
├── assets/
│   └── icon.png                 # 拡張機能のアイコン
├── package.json
└── README.md
```

## 技術仕様

### スプレッドシート構造

- **1行目**: ヘッダー行（列名）
- **2-4行目**: メタ情報行（部署、UserID、カウント行）
- **5行目以降**: 実際のタスクデータ

### データ取得

- **C列（index 2）**: タスクタイトル（凡事徹底）
- **D列（index 3）**: 期日
- **E列（index 4）**: 時間
- **CI列（index 86）**: 鵜木 義秀のステータス

### 期限判定ロジック

1. 今日の日付を取得
2. 2営業日後の日付を計算（土日除く）
3. タスクの期日をパース（M/D形式）
4. `期日 <= 2営業日後` のタスクのみ表示

## 注意事項

- **認証情報は機密情報です**。共有しないでください
  - `credentials.json`: OAuth クライアント情報
  - `token.json`: アクセストークン・リフレッシュトークン
- これらのファイルは`.gitignore`に含まれており、Gitにコミットされません
- アクセストークンは約1時間で期限切れになります
- 期限切れ時はリフレッシュトークンで更新してください

## 今後の改善案

- [ ] アクセストークンの自動更新機能
- [ ] 期日による並び替え
- [ ] タスクの優先度表示
- [ ] デスクトップ通知機能
- [ ] 複数シート対応
