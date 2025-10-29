/**
 * Google Sheets APIを直接REST APIで呼び出す
 * googleapis ライブラリは重すぎるため、fetchを使用
 */

import { readFileSync } from "fs";
import { join } from "path";

// .auth/token.jsonからアクセストークンを読み込む
function getAccessToken(): string {
  try {
    const tokenPath = join(__dirname, "../.auth/token.json");
    const tokenData = JSON.parse(readFileSync(tokenPath, "utf-8"));
    return tokenData.access_token;
  } catch (error) {
    throw new Error(
      "アクセストークンの読み込みに失敗しました。.auth/token.jsonが存在するか確認してください。"
    );
  }
}

export async function getSpreadsheetValues(spreadsheetId: string, range: string): Promise<any[][]> {
  const url = `https://sheets.googleapis.com/v4/spreadsheets/${spreadsheetId}/values/${encodeURIComponent(range)}`;
  const accessToken = getAccessToken();

  const response = await fetch(url, {
    headers: {
      "Authorization": `Bearer ${accessToken}`,
    },
  });

  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(`Sheets API エラー: ${response.status} ${response.statusText}`);
  }

  const data = await response.json();
  return data.values || [];
}
