# おかんタスク確認 - セットアップガイド

このガイドは、Raycast拡張機能「おかんタスク確認」を新しい環境にセットアップする手順を説明します。

## 📋 前提条件

- macOS
- Raycast がインストール済み
- Node.js (v16以上)
- npm または yarn

## 🚀 セットアップ手順

### ステップ1: リポジトリのクローン

```bash
git clone https://github.com/nokki-y/raycast_conf.git
cd raycast_conf/extensions/okan-tasks
```

### ステップ2: 依存関係のインストール

```bash
npm install
```

### ステップ3: OAuth認証のセットアップ

#### 3-1. 認証情報ファイルの配置

共有された `credentials.json` ファイルを `.auth` ディレクトリに配置します：

```bash
mkdir -p .auth
# credentials.json を .auth/ ディレクトリにコピー
```

**注意**: `credentials.json` は管理者から受け取ってください。

#### 3-2. OAuth認証フローの実行

```bash
npm run setup-auth
```

このコマンドを実行すると：

1. ブラウザが開き、Google認証ページが表示されます
2. あなたのGoogleアカウントでログイン
3. アクセス許可を承認
4. 表示される認証コードをコピー
5. ターミナルに認証コードを貼り付けて Enter

成功すると、`.auth/token.json` が自動的に作成されます。

#### 3-3. 認証情報の同期

認証情報をRaycast拡張ディレクトリに同期します：

```bash
npm run sync-auth
```

このコマンドは、`.auth/`ディレクトリの内容を`~/.config/raycast/extensions/raycast-okan/.auth/`にコピーします。

### ステップ4: Raycast Preferencesの設定

拡張機能を開発モードで起動：

```bash
npm run dev
```

Raycastで拡張機能が自動的に追加されます。次に、設定を行います：

1. Raycastを開く (⌘ + Space)
2. `Check Okan Tasks` と入力
3. 拡張機能の設定画面を開く (⌘ + K → Preferences)
4. 以下の項目を設定：

| 項目 | 説明 | 例 |
|------|------|-----|
| **Spreadsheet ID** | スプレッドシートのID | URLの `https://docs.google.com/spreadsheets/d/{ID}/` から取得 |
| **Sheet Name** | シート名 | `【Todo】タスク一覧` |
| **Sheet GID** | シートのGID | URLの `?gid={GID}` から取得 |
| **My Name** | あなたの名前 | スプレッドシートの列ヘッダーと完全一致させる |

### ステップ5: 動作確認

1. Raycastを開く (⌘ + Space)
2. `Check Okan Tasks` と入力
3. タスク一覧が表示されれば成功！

## 🔧 運用方法

### 開発モードで運用（推奨）

最もシンプルな方法です：

```bash
cd raycast_conf/extensions/okan-tasks
npm run dev
```

**メリット**:
- コード変更が即座に反映
- 最もシンプル

### プロダクションビルドで運用

より安定した運用が必要な場合：

```bash
npm run build
```

その後、Raycast Preferences → Extensions → Import Extension で `dist` フォルダを選択。

## ✨ 機能

- ✅ **期限フィルタリング**: 期限切れ + 2営業日以内のタスクのみ表示
- ✅ **ステータス自動判定**: 「完了」「対象外」を自動除外
- ✅ **直接編集**: タスクをクリックして該当セルで直接スプレッドシートを開く
- ✅ **自動トークン更新**: アクセストークンは自動的にリフレッシュされます

## 🔐 トークンの自動更新について

この拡張機能は、アクセストークンの有効期限を自動的にチェックし、期限切れ前（5分前）に自動的にリフレッシュします。

手動でトークンを更新する必要はありません。

## ❓ トラブルシューティング

### エラー: アクセストークンの読み込みに失敗

**原因**: `.auth/token.json` が存在しないか、認証に失敗しています。

**解決策**:
```bash
npm run setup-auth
```
を再度実行してください。

### エラー: 401 Unauthorized

**原因**: 認証情報が正しくないか、Google APIへのアクセス権限がありません。

**解決策**:
1. `credentials.json` が正しいか確認
2. Googleアカウントに適切な権限があるか確認
3. 再度 `npm run setup-auth` を実行

### エラー: 自分の列が見つかりません

**原因**: Preferencesの `My Name` がスプレッドシートの列ヘッダーと一致していません。

**解決策**:
- スプレッドシートの列ヘッダーを確認
- 空白文字や全角/半角に注意
- 完全一致させる必要があります

### タスクが表示されない

以下を確認してください：

1. スプレッドシートIDが正しいか
2. シート名が正しいか
3. あなたの列に「完了」「対象外」以外の値があるか（空欄も表示対象）
4. タスクの期日が**期限切れまたは2営業日以内**か

## 📞 サポート

問題が解決しない場合は、リポジトリ管理者に連絡してください。

---

🎉 セットアップ完了！おかんタスクを効率的に管理しましょう！
