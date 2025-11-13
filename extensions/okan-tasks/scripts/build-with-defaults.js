#!/usr/bin/env node

/**
 * デフォルト値をマージしてビルドするスクリプト
 *
 * 1. package.json を読み込み
 * 2. defaults.json を読み込み
 * 3. preferences にデフォルト値を注入
 * 4. 一時ファイル package.tmp.json を作成
 * 5. ray build を実行（一時ファイルを使用）
 * 6. 一時ファイルを削除
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

console.log('🚀 デフォルト値をマージしてビルド中...\n');

const packageJsonPath = path.resolve(__dirname, '../package.json');
const defaultsJsonPath = path.resolve(__dirname, '../defaults.json');
const tmpPackageJsonPath = path.resolve(__dirname, '../package.tmp.json');

// package.json を読み込み
if (!fs.existsSync(packageJsonPath)) {
  console.error('❌ package.json が見つかりません');
  process.exit(1);
}

const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, 'utf-8'));

// defaults.json を読み込み
let defaults = {};
if (fs.existsSync(defaultsJsonPath)) {
  defaults = JSON.parse(fs.readFileSync(defaultsJsonPath, 'utf-8'));
  console.log('✅ defaults.json を読み込みました');
} else {
  console.warn('⚠️  defaults.json が見つかりません（デフォルト値なしでビルド）');
}

// preferences にデフォルト値を注入
let injected = false;

if (packageJson.preferences && Object.keys(defaults).length > 0) {
  packageJson.preferences.forEach(pref => {
    if (pref.name === 'spreadsheetId' && defaults.spreadsheetId) {
      pref.default = defaults.spreadsheetId;
      console.log(`✅ spreadsheetId: ${defaults.spreadsheetId}`);
      injected = true;
    } else if (pref.name === 'sheetGid' && defaults.sheetGid) {
      pref.default = defaults.sheetGid;
      console.log(`✅ sheetGid: ${defaults.sheetGid}`);
      injected = true;
    } else if (pref.name === 'sheetName' && defaults.sheetName) {
      pref.default = defaults.sheetName;
      console.log(`✅ sheetName: ${defaults.sheetName}`);
      injected = true;
    } else if (pref.name === 'notificationInterval' && defaults.notificationIntervalOptions) {
      pref.data = defaults.notificationIntervalOptions;
      pref.default = defaults.notificationIntervalDefault;
      console.log(`✅ notificationInterval: ${defaults.buildMode}モード（オプション数: ${defaults.notificationIntervalOptions.length}、デフォルト: ${defaults.notificationIntervalDefault}分）`);
      injected = true;
    }
  });
}

if (!injected && Object.keys(defaults).length > 0) {
  console.warn('\n⚠️  デフォルト値が注入されませんでした');
}

// commands の interval を更新（開発モードの場合）
if (packageJson.commands && defaults.buildMode === 'development') {
  packageJson.commands.forEach(cmd => {
    if (cmd.name === 'notify-okan-tasks' && cmd.interval) {
      cmd.interval = '1m';
      console.log(`✅ notify-okan-tasks interval: 1m（開発モード）`);
    }
  });
}

// 一時ファイルに書き出し
fs.writeFileSync(tmpPackageJsonPath, JSON.stringify(packageJson, null, 2) + '\n', 'utf-8');
console.log('\n✅ 一時ファイル package.tmp.json を作成しました\n');

// ray build を実行
console.log('📦 ray build を実行中...\n');

try {
  // カレントディレクトリを拡張機能のルートに変更
  process.chdir(path.resolve(__dirname, '..'));

  // package.json を一時的にリネーム
  const packageJsonBackupPath = path.resolve(__dirname, '../package.json.backup');
  fs.renameSync(packageJsonPath, packageJsonBackupPath);
  fs.renameSync(tmpPackageJsonPath, packageJsonPath);

  // ray build を実行
  execSync('ray build -e dist', { stdio: 'inherit' });

  // package.json を元に戻す
  fs.renameSync(packageJsonPath, tmpPackageJsonPath);
  fs.renameSync(packageJsonBackupPath, packageJsonPath);

  console.log('\n✅ ビルドが完了しました');
} catch (error) {
  console.error('\n❌ ビルドに失敗しました');

  // package.json を元に戻す
  const packageJsonBackupPath = path.resolve(__dirname, '../package.json.backup');
  if (fs.existsSync(packageJsonBackupPath)) {
    if (fs.existsSync(packageJsonPath)) {
      fs.unlinkSync(packageJsonPath);
    }
    fs.renameSync(packageJsonBackupPath, packageJsonPath);
  }

  // 一時ファイルを削除
  if (fs.existsSync(tmpPackageJsonPath)) {
    fs.unlinkSync(tmpPackageJsonPath);
  }

  process.exit(1);
}

// 一時ファイルを削除
if (fs.existsSync(tmpPackageJsonPath)) {
  fs.unlinkSync(tmpPackageJsonPath);
  console.log('🧹 一時ファイルを削除しました\n');
}

console.log('✨ すべて完了しました\n');
