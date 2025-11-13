#!/usr/bin/env node

/**
 * Installation Check Script
 * このスクリプトはnpm installの前に実行され、環境をチェックします
 */

const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

// Node.jsバージョンチェック
const nodeVersion = process.version;
const requiredMajorVersion = 16;
const currentMajorVersion = parseInt(nodeVersion.slice(1).split('.')[0]);

console.log('🔍 環境チェック中...\n');

if (currentMajorVersion < requiredMajorVersion) {
  console.error(`❌ Node.js ${requiredMajorVersion}以上が必要です（現在: ${nodeVersion}）`);
  process.exit(1);
}

console.log(`✅ Node.js ${nodeVersion}`);

// npmバージョンチェック
try {
  const npmVersion = execSync('npm --version', { encoding: 'utf-8' }).trim();
  console.log(`✅ npm ${npmVersion}`);
} catch (error) {
  console.error('❌ npmが見つかりません');
  process.exit(1);
}

// Gitリポジトリチェック
const gitDir = path.join(process.cwd(), '.git');
if (!fs.existsSync(gitDir)) {
  console.warn('⚠️  .gitディレクトリが見つかりません。Gitリポジトリではない可能性があります。');
} else {
  console.log('✅ Gitリポジトリを検出');
}

console.log('\n✨ 環境チェック完了！npm installを続行します...\n');
process.exit(0);
