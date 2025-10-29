/**
 * Google Sheets APIを直接REST APIで呼び出す
 * googleapis ライブラリは重すぎるため、fetchを使用
 */

const ACCESS_TOKEN = "REMOVED_FOR_SECURITY";

export async function getSpreadsheetValues(spreadsheetId: string, range: string): Promise<any[][]> {
  const url = `https://sheets.googleapis.com/v4/spreadsheets/${spreadsheetId}/values/${encodeURIComponent(range)}`;

  const response = await fetch(url, {
    headers: {
      "Authorization": `Bearer ${ACCESS_TOKEN}`,
    },
  });

  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(`Sheets API エラー: ${response.status} ${response.statusText}`);
  }

  const data = await response.json();
  return data.values || [];
}
