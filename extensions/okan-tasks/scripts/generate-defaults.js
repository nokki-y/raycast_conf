#!/usr/bin/env node

/**
 * デフォルト値JSONを生成するスクリプト
 *
 * 拡張機能ディレクトリの .env から環境変数を読み込み、
 * defaults.json を生成します。
 */

const fs = require('fs');
const path = require('path');

console.log('🔧 デフォルト値JSON生成中...\n');

// 拡張機能ディレクトリの .env を読み込む
const envPath = path.resolve(__dirname, '../.env');

// .env ファイルが存在しない場合は警告して空のデフォルトを生成
if (!fs.existsSync(envPath)) {
  console.warn('⚠️  .env ファイルが見つかりません');
  console.warn('⚠️  空のデフォルト値で生成します\n');

  const emptyDefaults = {};
  const outputPath = path.resolve(__dirname, '../defaults.json');
  fs.writeFileSync(outputPath, JSON.stringify(emptyDefaults, null, 2) + '\n', 'utf-8');

  console.log('✨ defaults.json を生成しました（空）\n');
  process.exit(0);
}

// .env ファイルを読み込む（シンプルなパーサー）
const envContent = fs.readFileSync(envPath, 'utf-8');
const envVars = {};

envContent.split('\n').forEach(line => {
  const trimmed = line.trim();
  // コメント行と空行をスキップ
  if (!trimmed || trimmed.startsWith('#')) return;

  const match = trimmed.match(/^([A-Z_]+)=(.*)$/);
  if (match) {
    const [, key, value] = match;
    envVars[key] = value;
  }
});

// 必要な環境変数を取得
// コマンドラインから指定された環境変数を優先、なければ.envから、それもなければデフォルト値
const spreadsheetId = envVars.OKAN_SPREADSHEET_ID;
const sheetGid = envVars.OKAN_SHEET_GID;
const sheetName = envVars.OKAN_SHEET_NAME;
const buildMode = process.env.BUILD_MODE || envVars.BUILD_MODE || 'production';

// デフォルト値オブジェクトを作成
const defaults = {
  buildMode: buildMode
};

console.log(`🔨 ビルドモード: ${buildMode}\n`);

if (spreadsheetId) {
  defaults.spreadsheetId = spreadsheetId;
  console.log(`✅ spreadsheetId: ${spreadsheetId}`);
}

if (sheetGid) {
  defaults.sheetGid = sheetGid;
  console.log(`✅ sheetGid: ${sheetGid}`);
}

if (sheetName) {
  defaults.sheetName = sheetName;
  console.log(`✅ sheetName: ${sheetName}`);
}

// BUILD_MODEに応じた通知間隔の設定を追加
if (buildMode === 'development') {
  defaults.notificationIntervalOptions = [
    { title: "1分（テスト用）", value: "1" },
    { title: "30分", value: "30" },
    { title: "1時間", value: "60" },
    { title: "2時間", value: "120" },
    { title: "4時間", value: "240" }
  ];
  defaults.notificationIntervalDefault = "1";
  console.log('✅ notificationInterval: 開発モード（1分オプション有効、デフォルト1分）');
} else {
  defaults.notificationIntervalOptions = [
    { title: "30分", value: "30" },
    { title: "1時間（推奨）", value: "60" },
    { title: "2時間", value: "120" },
    { title: "4時間", value: "240" }
  ];
  defaults.notificationIntervalDefault = "60";
  console.log('✅ notificationInterval: 本番モード（デフォルト1時間）');
}

if (Object.keys(defaults).length === 0) {
  console.warn('\n⚠️  環境変数が設定されていないため、デフォルト値は空です');
  console.warn('⚠️  .env ファイルに以下の変数を設定してください:');
  console.warn('   - OKAN_SPREADSHEET_ID');
  console.warn('   - OKAN_SHEET_GID');
  console.warn('   - OKAN_SHEET_NAME\n');
}

// defaults.json を出力
const outputPath = path.resolve(__dirname, '../defaults.json');
fs.writeFileSync(outputPath, JSON.stringify(defaults, null, 2) + '\n', 'utf-8');

console.log('\n✨ defaults.json を生成しました\n');
