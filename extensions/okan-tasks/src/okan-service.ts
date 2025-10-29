import { google } from "googleapis";
import { getAuthClient } from "./google-auth";
import { getPreferenceValues } from "@raycast/api";

export interface OkanTask {
  rowNumber: number;
  taskName: string;
  date: string;
  time: string;
  assignee: string;
  status: string;
  url: string;
}

interface Preferences {
  spreadsheetId: string;
  sheetName: string;
  sheetGid: string;
  myName: string;
}

/**
 * Raycastのpreferencesから設定を取得
 */
function getConfig() {
  const preferences = getPreferenceValues<Preferences>();

  return {
    spreadsheetId: preferences.spreadsheetId,
    sheetName: preferences.sheetName,
    myName: preferences.myName,
    sheetGid: preferences.sheetGid,
  };
}

/**
 * スプレッドシートから未完了タスクを取得
 */
export async function getIncompleteTasks(): Promise<OkanTask[]> {
  const config = getConfig();
  const auth = await getAuthClient();
  const sheets = google.sheets({ version: "v4", auth });

  // シート全体のデータを取得
  const range = `${config.sheetName}!A1:Z1000`;
  const response = await sheets.spreadsheets.values.get({
    spreadsheetId: config.spreadsheetId,
    range,
  });

  const rows = response.data.values;
  if (!rows || rows.length === 0) {
    return [];
  }

  // ヘッダー行から自分の名前の列を探す
  const headerRow = rows[0];
  const myColumnIndex = headerRow.findIndex((cell) => cell === config.myName);

  if (myColumnIndex === -1) {
    throw new Error(`スプレッドシートに「${config.myName}」の列が見つかりません`);
  }

  // タスクをフィルタリング
  const tasks: OkanTask[] = [];
  for (let i = 1; i < rows.length; i++) {
    const row = rows[i];
    const status = row[myColumnIndex] || "";

    // 「完了」「対象外」以外のタスクを抽出
    if (status !== "完了" && status !== "対象外" && status.trim() !== "") {
      const taskName = row[2] || ""; // C列: 凡事徹底
      const date = row[3] || ""; // D列: 期日
      const time = row[4] || ""; // E列: 時間
      const assignee = row[5] || ""; // F列: 記入者

      // タスク名が空の場合はスキップ
      if (taskName.trim() === "") {
        continue;
      }

      // セルのURLを生成 (行番号は1から始まるので+1、列はA=0)
      const cellUrl = `https://docs.google.com/spreadsheets/d/${config.spreadsheetId}/edit?gid=${config.sheetGid}#gid=${config.sheetGid}&range=A${i + 1}`;

      tasks.push({
        rowNumber: i + 1,
        taskName,
        date,
        time,
        assignee,
        status,
        url: cellUrl,
      });
    }
  }

  return tasks;
}
