# おかんタスク確認 - 配布ガイド（管理者向け）

このガイドは、拡張機能を他のユーザーに配布する管理者向けの手順を説明します。

## 📦 配布用パッケージの作成

### 1. リリースパッケージをビルド

```bash
cd extensions/okan-tasks
npm run release
```

このコマンドで `release/okan-tasks-raycast/` ディレクトリが作成されます。

### 2. 作成されるファイル構成

```
release/okan-tasks-raycast/
├── dist/                  # ビルド済みの拡張機能
├── assets/                # アイコンなどのアセット
├── .auth/                 # 空のディレクトリ（ユーザーが認証情報を配置）
├── package.json           # メタデータ
└── INSTALL.md             # エンドユーザー向けインストール手順
```

## 🚀 配布手順

### 方法1: Zipファイルで配布（推奨）

```bash
cd release
zip -r okan-tasks-raycast.zip okan-tasks-raycast/
```

配布先に以下を送付：
1. `okan-tasks-raycast.zip`
2. `credentials.json`（別ファイルとして）
3. インストール手順（下記参照）

### 方法2: 共有フォルダで配布

`release/okan-tasks-raycast/` フォルダをGoogle DriveやDropboxなどの共有フォルダに配置し、配布先にアクセス権を付与。

## 📋 配布先への指示

配布先に以下の手順を伝えます：

---

### インストール手順（配布先向け）

1. **ダウンロード**
   - `okan-tasks-raycast.zip` をダウンロードして解凍
   - または共有フォルダから `okan-tasks-raycast` フォルダをコピー

2. **認証情報の配置**
   ```bash
   # okan-tasks-raycastフォルダに移動
   cd okan-tasks-raycast

   # credentials.jsonを.authディレクトリに配置
   mv ~/Downloads/credentials.json .auth/
   ```

3. **初回認証**
   - ブラウザで以下のURLを開く: https://accounts.google.com/o/oauth2/auth?...
   - Googleアカウントでログイン
   - アクセスを許可
   - 表示される認証コードをメモ

   **注意**: 認証URLと認証コードの入力方法は別途指示

4. **Raycastにインストール**
   - Raycast Preferences → Extensions → **+** → **Add Extension**
   - `okan-tasks-raycast` フォルダを選択
   - **Install Extension** をクリック

5. **設定**
   - Raycastで `Check Okan Tasks` を検索
   - ⌘ + K → Preferences で設定画面を開く
   - 以下を入力（管理者から共有された値を使用）:
     - Spreadsheet ID
     - Sheet Name
     - Sheet GID
     - My Name（自分の名前）

6. **動作確認**
   - Raycastで `Check Okan Tasks` を実行
   - タスクが表示されればOK！

---

## 🔐 認証情報の管理

### credentials.jsonの共有方法

**重要**: `credentials.json` は機密情報です。安全に共有してください。

推奨方法：
- 暗号化されたメッセージング（Signal、1Passwordなど）
- パスワード付きZip
- 企業の機密情報共有システム

### 複数ユーザーでの共有

現在の設定（デスクトップアプリ）では、同じ `credentials.json` を複数ユーザーで共有できます。各ユーザーは初回認証時に自分のGoogleアカウントで認証を行い、個別の `token.json` が作成されます。

## 🔄 アップデート配布

拡張機能を更新する場合：

1. コードを修正
2. `npm run release` で新しいパッケージを作成
3. 配布先に新しいパッケージを送付
4. 配布先は既存の `.auth/` ディレクトリを保持したまま、他のファイルを上書き

`.auth/` ディレクトリの認証情報は保持されるため、再認証は不要です。

## 📊 サポート対応

### よくある問題

**1. 認証エラー**
- `credentials.json` が正しく配置されているか確認
- 認証コードが正しく入力されたか確認

**2. タスクが表示されない**
- Spreadsheet ID が正しいか
- Sheet Name が正しいか（大文字小文字、スペースに注意）
- My Name がスプレッドシートの列ヘッダーと完全一致しているか

**3. 401 Unauthorized エラー**
- 通常は自動リフレッシュされるが、もし発生した場合は再認証を依頼

## 🛠️ 開発者向け補足

### なぜビルド済みを配布するのか

- エンドユーザーにNode.js環境が不要
- セットアップが簡単（ビルド不要）
- 配布が容易（単一フォルダで完結）

### ソースコードからのビルド

開発者や技術者向けには、GitHubリポジトリのREADME.mdを参照してもらい、ソースコードからビルドすることも可能です。

## 📝 配布チェックリスト

配布前に確認：

- [ ] `npm run release` でビルド成功
- [ ] `release/okan-tasks-raycast/` にINSTALL.mdが含まれている
- [ ] `credentials.json` を別途準備
- [ ] 配布先への指示メールを準備
- [ ] テスト環境で動作確認済み

---

このガイドに従って配布すれば、エンドユーザーは開発環境なしで拡張機能を利用できます。
