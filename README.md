# ryacast_conf

Raycast用のカスタムスクリプトコレクション

## スクリプト一覧

### 📝 memo.sh
Google Drive内の作業ディレクトリにメモファイルを作成し、Cursorエディタで開く

**使用方法**: 
```
Raycast → "memo" → ファイル名を入力
```

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
```
Raycast → "Prevent Sleep Timer" → 分数を入力（例: 30, 60, 120）
```

**機能**:
- 指定した分数だけスリープを防止
- 終了予定時刻を表示
- 自動的に終了

## セットアップ

1. このリポジトリをクローン
2. Raycastの設定でスクリプトディレクトリとして指定
3. スクリプトが自動的にRaycastに認識される

## 必要な環境

- macOS
- Raycast
- Bash