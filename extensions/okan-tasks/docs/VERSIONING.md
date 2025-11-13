# バージョン管理ガイド

Okan Tasks拡張機能のバージョン管理とリリースプロセスについて説明します。

## バージョン管理の仕組み

### バージョンファイル

- **場所**: `extensions/okan-tasks/VERSION`
- **形式**: セマンティックバージョニング（X.Y.Z）
- **初期値**: `0.0.0`

### Gitタグ

各リリースには拡張機能名をプレフィックスとしたGitタグが作成されます：

```
okan-v1.0.0
okan-v1.1.0
okan-v2.0.0
```

これにより、同じリポジトリで複数の拡張機能を管理できます。

## リリースコマンド

### 基本的な使い方

```bash
# プロジェクトルートから実行
npm run release:okan <バージョン> [オプション]

# または拡張機能ディレクトリから実行
cd extensions/okan-tasks
bash scripts/release.sh <バージョン> [オプション]
```

### バージョン指定方法

#### 1. セマンティックバージョニング（推奨）

```bash
# パッチバージョンアップ (0.0.0 → 0.0.1)
npm run release:okan patch

# マイナーバージョンアップ (0.0.1 → 0.1.0)
npm run release:okan minor

# メジャーバージョンアップ (0.1.0 → 1.0.0)
npm run release:okan major
```

#### 2. 直接バージョン指定

```bash
# 特定のバージョンを指定
npm run release:okan 1.2.3
```

### オプション

```bash
# 開発モードでリリース（1分間隔オプション有効）
npm run release:okan patch --dev

# Gitタグを作成しない
npm run release:okan patch --no-tag

# ビルド成果物を残す（デバッグ用）
npm run release:okan patch --no-cleanup
```

## リリースプロセス

リリーススクリプトは以下の処理を自動的に実行します：

### 1. 環境チェック
- `.env`ファイルの存在確認
- 認証情報（credentials.json, token.json）の存在確認

### 2. バージョン管理
- `VERSION`ファイルの読み込み
- 新しいバージョンの計算
- バージョンの妥当性チェック

### 3. ビルド実行
- 本番モード: `npm run build`
- 開発モード: `npm run build:dev`

### 4. リリースパッケージ作成
- Raycastビルド成果物のコピー
- 認証情報のコピー
- VERSIONファイルの追加
- インストールガイドの生成
- Zipファイルの作成

### 5. リリースノート生成
- ビルド日時
- Node.js/npmバージョン
- 含まれるファイル一覧
- インストール手順

### 6. Gitタグ作成（オプション）
- `VERSION`ファイルの更新
- コミット作成: `release(okan): v{version}`
- Gitタグ作成: `okan-v{version}`

## 出力ディレクトリ

### 本番ビルド

```
extensions/okan-tasks/release/v{version}/
├── okan-tasks-v{version}/
│   ├── assets/.auth/
│   ├── *.js
│   ├── *.js.map
│   ├── package.json
│   └── VERSION
├── okan-tasks-v{version}.zip
├── INSTALL.md
└── RELEASE_NOTES.md
```

### 開発ビルド

```
extensions/okan-tasks/release/dev/
└── raycast-okan/
    ├── assets/.auth/
    ├── *.js
    ├── *.js.map
    └── package.json
```

## GitHub連携

### タグのプッシュ

```bash
# コミットとタグをプッシュ
git push origin main
git push origin okan-v1.0.0
```

### GitHubリリースの作成（手動）

1. GitHubのリポジトリページを開く
2. "Releases" → "Create a new release"
3. タグを選択: `okan-v1.0.0`
4. リリースタイトル: `Okan Tasks v1.0.0`
5. `release/v1.0.0/RELEASE_NOTES.md`の内容をコピー
6. `release/v1.0.0/okan-tasks-v1.0.0.zip`をアップロード

## 複数拡張機能の管理

このリポジトリで複数の拡張機能を管理する場合：

### 新しい拡張機能の追加

1. **ディレクトリ構成**:
   ```
   extensions/
   ├── okan-tasks/
   │   ├── VERSION (独立したバージョン管理)
   │   └── scripts/release.sh
   └── new-extension/
       ├── VERSION
       └── scripts/release.sh
   ```

2. **タグ命名規則**:
   ```
   okan-v1.0.0
   new-extension-v1.0.0
   ```

3. **リリーススクリプトの複製**:
   ```bash
   # release.shをコピーして拡張機能名を変更
   cp extensions/okan-tasks/scripts/release.sh extensions/new-extension/scripts/

   # スクリプト内の "okan" を "new-extension" に置換
   ```

### リリース例

```bash
# Okan Tasksのリリース
npm run release:okan patch

# 別の拡張機能のリリース（将来）
npm run release:new-extension minor
```

## トラブルシューティング

### Q: リリースがタイムアウトする

A: 環境チェックでハングしている可能性があります。`--no-tag`オプションで環境チェックをスキップできます。

### Q: 認証情報が見つからないエラー

A: `extensions/okan-tasks/assets/.auth/`に以下のファイルがあることを確認してください：
- `credentials.json`
- `token.json`

### Q: バージョンが更新されない

A: `extensions/okan-tasks/VERSION`ファイルが正しく更新されているか確認してください。

### Q: Gitタグが既に存在する

A: 同じバージョンで再リリースする場合は、既存のタグを削除してください：
```bash
git tag -d okan-v1.0.0
git push origin :refs/tags/okan-v1.0.0
```

## 参考

- [セマンティックバージョニング](https://semver.org/lang/ja/)
- [Raycast Extensions ドキュメント](https://developers.raycast.com/)
