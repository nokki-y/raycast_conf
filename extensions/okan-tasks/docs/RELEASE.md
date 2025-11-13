# Okan Tasks リリースガイド

このドキュメントは、Okan Tasks拡張機能のリリースプロセスを説明します。

## 📋 前提条件

リリースを実行する前に、以下を確認してください：

### 必須項目

1. **環境変数の設定**
   ```bash
   # extensions/okan-tasks/.env が存在し、以下の変数が設定されている
   OKAN_SPREADSHEET_ID=...
   OKAN_SHEET_GID=...
   OKAN_SHEET_NAME=...
   ```

2. **認証情報の準備**
   ```bash
   # extensions/okan-tasks/assets/.auth/ に以下が存在する
   - credentials.json
   - token.json
   ```

3. **拡張機能のビルドが成功する**
   ```bash
   cd extensions/okan-tasks
   npm run build
   ```

## 🚀 リリース方法

### 基本的な使い方

```bash
# パッチバージョンアップ (例: 1.0.0 → 1.0.1)
npm run release:okan patch

# マイナーバージョンアップ (例: 1.0.0 → 1.1.0)
npm run release:okan minor

# メジャーバージョンアップ (例: 1.0.0 → 2.0.0)
npm run release:okan major

# 特定のバージョンを指定
npm run release:okan 1.2.3
```

### オプション

```bash
# Gitタグを作成しない（テスト用）
npm run release:okan -- patch --no-tag

# ビルド成果物を削除しない（デバッグ用）
npm run release:okan -- patch --no-cleanup
```

### ヘルプ表示

```bash
npm run release:okan -- --help
```

## 📦 リリースプロセス

リリーススクリプトは以下の処理を自動的に実行します：

### 1. 事前チェック
- ✅ 環境変数ファイル（.env）の存在確認
- ✅ 必要な環境変数の設定確認
- ✅ 認証情報の存在確認

### 2. ビルド
- 🔨 拡張機能のビルド実行（`npm run build`）
- 📦 デフォルト値の自動注入

### 3. パッケージング
- 📁 リリースディレクトリの作成（`release/vX.Y.Z/`）
- 📋 Raycastビルド出力のコピー
- 🔐 認証情報のコピー
- 📄 バージョンファイルの作成
- 📝 インストールガイドの生成
- 🗜️ Zipファイルの作成

### 4. ドキュメント生成
- 📝 INSTALL.md - エンドユーザー向けインストールガイド
- 📝 RELEASE_NOTES.md - リリースノート

### 5. バージョン管理（デフォルト）
- 🏷️ VERSIONファイルの更新
- 💾 Gitコミット作成
- 🏷️ Gitタグ作成（`vX.Y.Z`）

## 📂 生成されるファイル

リリース後、以下のファイルが生成されます：

```
release/
└── vX.Y.Z/
    ├── okan-tasks-vX.Y.Z/          # 配布用パッケージ
    │   ├── assets/
    │   │   └── .auth/              # 認証情報
    │   ├── INSTALL.md              # インストールガイド
    │   └── VERSION                 # バージョン情報
    ├── okan-tasks-vX.Y.Z.zip       # 配布用Zipファイル
    └── RELEASE_NOTES.md            # リリースノート
```

## 🎯 配布手順

### 1. Zipファイルの配布

```bash
# 生成されたZipファイルを配布
release/vX.Y.Z/okan-tasks-vX.Y.Z.zip
```

### 2. Git変更のプッシュ（Gitタグを作成した場合）

```bash
# メインブランチをプッシュ
git push origin main

# タグをプッシュ
git push origin vX.Y.Z
```

### 3. 配布先への案内

受け取った人に以下を案内：
1. Zipファイルを解凍
2. `INSTALL.md` の手順に従ってインストール
3. **My Name**（担当者名）のみ設定が必要

## 🔐 セキュリティ注意事項

### 重要

- ⚠️ リリースパッケージには**Google OAuth認証情報**が含まれます
- ⚠️ 配布先は**信頼できる相手のみ**に限定してください
- ⚠️ 公開リポジトリやパブリックな場所にアップロードしないでください

### 認証情報の扱い

リリースパッケージに含まれる認証情報：
- `credentials.json` - OAuth クライアント情報
- `token.json` - アクセストークン・リフレッシュトークン

これらは組織内での限定的な使用を想定しています。

## 🐛 トラブルシューティング

### エラー: .envファイルが見つかりません

```bash
cd extensions/okan-tasks
cp .env.example .env
# .envを編集して実際の値を設定
```

### エラー: 認証情報が見つかりません

```bash
cd extensions/okan-tasks
npm run setup-auth
# 認証フローを完了
```

### エラー: Raycastビルド出力が見つかりません

```bash
cd extensions/okan-tasks
npm run build
# ビルドが成功することを確認してから再度リリース実行
```

### ビルドが失敗する

```bash
# 依存関係を再インストール
cd extensions/okan-tasks
rm -rf node_modules
npm install
npm run build
```

## 📝 バージョニングガイドライン

セマンティックバージョニング（X.Y.Z）を採用：

- **X (Major)**: 破壊的変更（APIの大幅な変更、非互換な変更）
- **Y (Minor)**: 後方互換性のある機能追加
- **Z (Patch)**: 後方互換性のあるバグ修正

### 例

- `1.0.0 → 1.0.1`: バグ修正 → `patch`
- `1.0.1 → 1.1.0`: 新機能追加 → `minor`
- `1.1.0 → 2.0.0`: 大幅な変更 → `major`

## 🔄 リリース履歴の確認

```bash
# Gitタグでリリース履歴を確認
git tag -l "v*"

# 特定のバージョンの詳細を確認
git show v1.0.0
```

## 📞 サポート

問題が発生した場合は、開発チームに連絡してください。

---

**最終更新**: 2025-01-04
