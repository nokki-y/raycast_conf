# セキュリティガイドライン

このリポジトリはパブリックリポジトリであるため、秘匿情報のコミットを厳格に防止する必要があります。

## 🔒 秘匿情報検知システム

このリポジトリには3層の秘匿情報検知システムが実装されています。

### レイヤー1: Pre-commit Hook（ローカル防御）

コミット前にローカル環境で秘匿情報を検知します。

**使用ツール:**
- `detect-secrets` - ベースライン方式の秘匿情報スキャン
- `gitleaks` - 高速な秘匿情報検知
- `pre-commit-hooks` - 秘密鍵、大容量ファイル等の検知

### レイヤー2: GitHub Actions（CI防御）

プッシュ後およびPR時に自動でスキャンを実行します。

**使用ツール:**
- `trufflehog` - Git履歴全体の詳細スキャン
- `gitleaks` - 追加の検証層
- `detect-secrets` - ベースライン検証

### レイヤー3: GitHub Secret Scanning（継続的監視）

GitHubの標準機能により、既知のパターンを自動検知します（パブリックリポジトリでは自動有効）。

---

## 🚀 セットアップ手順

### 1. Pre-commit のインストール

```bash
# Homebrewを使用する場合
brew install pre-commit

# pipを使用する場合
pip install pre-commit

# インストール確認
pre-commit --version
```

### 2. Gitleaks のインストール

```bash
# Homebrewを使用する場合
brew install gitleaks

# 直接ダウンロードする場合（Linux/macOS）
# https://github.com/gitleaks/gitleaks/releases
```

### 3. detect-secrets のインストール

```bash
pip install detect-secrets
```

### 4. Pre-commit フックの有効化

```bash
# リポジトリのルートディレクトリで実行
cd /path/to/raycast_conf
pre-commit install
```

これで、次回のコミット時から自動的に秘匿情報スキャンが実行されます。

### 5. 既存コードのスキャン（初回のみ）

```bash
# 全ファイルをスキャン
pre-commit run --all-files

# 特定のツールのみ実行
pre-commit run detect-secrets --all-files
pre-commit run gitleaks --all-files
```

---

## 📋 検知対象の秘匿情報

以下のような情報が検知対象となります:

### API キー・トークン
- ✅ AWS アクセスキー（`AKIA...`）
- ✅ GitHub Personal Access Token（`ghp_...`、`gho_...`）
- ✅ OpenAI API Key（`sk-...`）
- ✅ Anthropic API Key（`sk-ant-...`）
- ✅ Slack Webhook URL
- ✅ Raycast Extension Token
- ✅ 一般的なAPI キー（`api_key=...`）

### 認証情報
- ✅ プライベートキー（PEM形式）
- ✅ SSH キー（id_rsa等）
- ✅ 証明書ファイル（.pem, .key, .p12等）
- ✅ パスワード文字列

### 環境変数ファイル
- ✅ `.env` ファイル
- ✅ `credentials.json`
- ✅ `token.json`

---

## 🛠️ 誤検知への対応

### detect-secrets での誤検知

正当なコードが誤検知された場合、ベースラインを更新します:

```bash
# ベースラインを更新（新しい誤検知を追加）
detect-secrets scan --baseline .secrets.baseline

# 対話的に誤検知を確認・承認
detect-secrets audit .secrets.baseline
```

### gitleaks での誤検知

[.gitleaks.toml](.gitleaks.toml) の `[allowlist]` セクションに追加します:

```toml
[allowlist]
regexes = [
  '''example-dummy-key''',  # 例: テスト用のダミーキー
]
```

### 特定ファイルの除外

```toml
[allowlist]
paths = [
  '''tests/fixtures/.*''',  # テストフィクスチャ全体
]
```

---

## ⚠️ もし秘匿情報をコミットしてしまったら

### 1. **即座に無効化**
- 漏洩したキー・トークンを無効化（revoke）
- 関連サービスのパスワードを変更

### 2. **履歴から削除**

⚠️ 注意: 履歴の書き換えは慎重に行ってください

```bash
# BFG Repo-Cleanerを使用（推奨）
# https://rtyley.github.io/bfg-repo-cleaner/
brew install bfg

# 秘匿情報を含むファイルを削除
bfg --delete-files credentials.json

# または、特定の文字列を削除
bfg --replace-text passwords.txt

# Gitの履歴を整理
git reflog expire --expire=now --all
git gc --prune=now --aggressive

# 強制プッシュ（慎重に！）
git push --force
```

### 3. **GitHub に報告**

パブリックリポジトリで秘匿情報が漏洩した場合:
- GitHub Security Advisory を作成
- 影響範囲を調査

---

## 🔍 手動スキャン

### ローカルでの手動スキャン

```bash
# Gitleaksで全履歴をスキャン
gitleaks detect --config .gitleaks.toml --verbose

# Detect Secretsでスキャン
detect-secrets scan

# TruffleHogでスキャン（GitHub Actionsと同じツール）
docker run --rm -v "$(pwd):/src" trufflesecurity/trufflehog:latest git file:///src --only-verified
```

### GitHub Actions での手動実行

1. GitHub リポジトリの **Actions** タブを開く
2. **Secret Scanning** ワークフローを選択
3. **Run workflow** をクリック

---

## 📚 除外すべきファイル（.gitignore）

[.gitignore](.gitignore) には以下が設定されています:

```gitignore
# 環境変数
.env
.env.*

# 認証情報
**/credentials.json
**/token.json
**/.auth/

# SSH キー
*.pem
*.key
id_rsa

# API キー
*secret*
*apikey*
secrets.yaml
```

---

## 🎯 ベストプラクティス

### ✅ DO（推奨）

- ✅ 秘匿情報は環境変数（`.env`）で管理
- ✅ `.env.example` でテンプレートを提供
- ✅ コミット前に `git diff` で変更内容を確認
- ✅ 定期的に `pre-commit run --all-files` でスキャン
- ✅ CI/CDの結果を確認してからマージ

### ❌ DON'T（禁止）

- ❌ コード内にハードコードでキーを記述
- ❌ コミットメッセージに秘匿情報を含める
- ❌ スクリーンショットにキーを含める
- ❌ pre-commit フックをスキップ（`--no-verify`）
- ❌ テスト用でも本物のキーを使用

---

## 🆘 トラブルシューティング

### pre-commit が動作しない

```bash
# フックの再インストール
pre-commit uninstall
pre-commit install

# キャッシュをクリア
pre-commit clean
```

### CI/CDでスキャンが失敗する

```bash
# ローカルで同じスキャンを実行
pre-commit run --all-files

# 詳細ログを確認
gitleaks detect --verbose --config .gitleaks.toml
```

### 誤検知が多すぎる

1. [.gitleaks.toml](.gitleaks.toml) の `[allowlist]` を調整
2. `.secrets.baseline` を更新
3. 必要に応じて `.pre-commit-config.yaml` の除外設定を調整

---

## 📞 サポート

質問や問題がある場合:

1. [GitHub Issues](../../issues) で報告
2. セキュリティに関わる緊急の問題は、リポジトリオーナーに直接連絡

---

## 📖 参考リンク

- [Gitleaks Documentation](https://github.com/gitleaks/gitleaks)
- [detect-secrets Documentation](https://github.com/Yelp/detect-secrets)
- [TruffleHog Documentation](https://github.com/trufflesecurity/trufflehog)
- [Pre-commit Framework](https://pre-commit.com/)
- [GitHub Secret Scanning](https://docs.github.com/en/code-security/secret-scanning)

---

**最終更新:** 2025-11-04
