import { List, showToast, Toast, getPreferenceValues, Action, ActionPanel, open } from "@raycast/api";
import React, { useEffect, useState } from "react";
import { getSpreadsheetValues } from "./sheets-api";

interface Preferences {
  spreadsheetId: string;
  sheetName: string;
  sheetGid: string;
  myName: string;
}

interface Task {
  rowIndex: number;
  title: string;
  status: string;
  deadline: string;
  columnIndex: number; // ステータス列のインデックス
}

// 列インデックスを列名に変換（0 -> A, 25 -> Z, 26 -> AA, 86 -> CI）
function columnIndexToName(index: number): string {
  let columnName = "";
  let num = index;
  while (num >= 0) {
    columnName = String.fromCharCode((num % 26) + 65) + columnName;
    num = Math.floor(num / 26) - 1;
  }
  return columnName;
}

export default function Command() {
  const [isLoading, setIsLoading] = useState(true);
  const [tasks, setTasks] = useState<Task[]>([]);

  useEffect(() => {
    async function loadTasks() {
      try {
        const preferences = getPreferenceValues<Preferences>();

        await showToast({
          style: Toast.Style.Animated,
          title: "データ取得中",
          message: "スプレッドシートからデータを取得しています...",
        });

        // 範囲を指定せず、データが入っている範囲をすべて取得
        const range = `${preferences.sheetName}`;
        const values = await getSpreadsheetValues(preferences.spreadsheetId, range);

        if (values.length === 0) {
          throw new Error("データが取得できませんでした");
        }

        // ヘッダー行から自分の列を特定
        const headers = values[0];
        let myColumnIndex = headers.findIndex((header: string) => header === preferences.myName);

        // 完全一致で見つからない場合は、含まれているかで検索
        if (myColumnIndex === -1) {
          myColumnIndex = headers.findIndex((header: string) =>
            header && header.includes(preferences.myName.replace(/\s+/g, ''))
          );
        }

        // それでも見つからない場合は、姓だけで検索
        if (myColumnIndex === -1) {
          const lastName = preferences.myName.split(/\s+/)[0];
          myColumnIndex = headers.findIndex((header: string) =>
            header && header.includes(lastName)
          );
        }

        if (myColumnIndex === -1) {
          throw new Error(`自分の列が見つかりません: ${preferences.myName}`);
        }
        const filteredTasks: Task[] = [];

        // 行1: ヘッダー行
        // 行2-4: メタ情報行（部署、UserID、カウント行）
        // 行5以降: 実際のタスクデータ
        // したがって、インデックス4（5行目）から処理を開始
        const DATA_START_ROW = 4; // 0-indexed（5行目 = インデックス4）

        // 今日の日付を取得
        const today = new Date();
        today.setHours(0, 0, 0, 0);

        // 2営業日後の日付を計算（土日を除く）
        const getBusinessDaysLater = (date: Date, days: number): Date => {
          const result = new Date(date);
          let addedDays = 0;
          while (addedDays < days) {
            result.setDate(result.getDate() + 1);
            // 土曜(6)と日曜(0)を除く
            if (result.getDay() !== 0 && result.getDay() !== 6) {
              addedDays++;
            }
          }
          return result;
        };

        const twoDaysLater = getBusinessDaysLater(today, 2);

        for (let i = DATA_START_ROW; i < values.length; i++) {
          const row = values[i];
          const status = row[myColumnIndex] || "";
          const title = row[2] || ""; // C列: 凡事徹底
          const deadline = row[3] || ""; // D列: 期日

          // 「完了」「対象外」以外のタスクを抽出（空文字列＝未着手も含む）
          if (status !== "完了" && status !== "対象外" && title && deadline) {
            // 期日をパース（M/D形式）
            const deadlineParts = deadline.match(/(\d+)\/(\d+)/);
            if (deadlineParts) {
              const month = parseInt(deadlineParts[1], 10);
              const day = parseInt(deadlineParts[2], 10);
              const deadlineDate = new Date(today.getFullYear(), month - 1, day);
              deadlineDate.setHours(0, 0, 0, 0);

              // 期限切れ または 2営業日以内の場合のみ追加
              if (deadlineDate <= twoDaysLater) {
                filteredTasks.push({
                  rowIndex: i + 1, // スプレッドシートの行番号 (1-indexed)
                  title,
                  status: status || "未着手", // 空の場合は「未着手」と表示
                  deadline,
                  columnIndex: myColumnIndex, // ステータス列のインデックス
                });
              }
            }
          }
        }

        setTasks(filteredTasks);

        await showToast({
          style: Toast.Style.Success,
          title: "取得完了",
          message: `${filteredTasks.length}件のタスクを取得しました`,
        });

        setIsLoading(false);
      } catch (err) {
        await showToast({
          style: Toast.Style.Failure,
          title: "エラー",
          message: String(err),
        });
        setIsLoading(false);
      }
    }

    loadTasks();
  }, []);

  const preferences = getPreferenceValues<Preferences>();

  return (
    <List isLoading={isLoading}>
      {tasks.length === 0 && !isLoading ? (
        <List.Item title="タスクはありません" />
      ) : (
        tasks.map((task, index) => (
          <List.Item
            key={index}
            title={task.title}
            subtitle={`ステータス: ${task.status}`}
            accessories={[{ text: task.deadline }]}
            actions={
              <ActionPanel>
                <Action
                  title="スプレッドシートで開く"
                  onAction={() => {
                    const columnName = columnIndexToName(task.columnIndex);
                    const url = `https://docs.google.com/spreadsheets/d/${preferences.spreadsheetId}/edit#gid=${preferences.sheetGid}&range=${columnName}${task.rowIndex}`;
                    open(url);
                  }}
                />
              </ActionPanel>
            }
          />
        ))
      )}
    </List>
  );
}
