import { List, showToast, Toast, getPreferenceValues, Action, ActionPanel, open, Color, Icon } from "@raycast/api";
import React, { useEffect, useState } from "react";
import { getSpreadsheetValues } from "./sheets-api";
import { parseDeadline, formatDeadline } from "./utils/date-parser";

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
  deadlineDate: Date; // 期日のDateオブジェクト
}

type TaskCategory = "completed" | "overdue" | "upcoming" | "other";

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

// ステータスに応じたバッジの色とアイコンを返す
function getStatusBadge(status: string): { color: Color; icon: Icon } {
  switch (status) {
    case "未着手":
      return { color: Color.Red, icon: Icon.Circle };
    case "着手中":
      return { color: Color.Yellow, icon: Icon.CircleProgress };
    case "確認待ち":
      return { color: Color.Blue, icon: Icon.QuestionMark };
    case "完了":
      return { color: Color.Green, icon: Icon.CheckCircle };
    case "対象外":
      return { color: Color.SecondaryText, icon: Icon.XMarkCircle };
    default:
      return { color: Color.SecondaryText, icon: Icon.Circle };
  }
}

// タスクのカテゴリを判定
function categorizeTask(task: Task, today: Date, twoDaysLater: Date): TaskCategory {
  // 完了済み
  if (task.status === "完了") {
    return "completed";
  }

  // 期日切れ（今日より前）
  if (task.deadlineDate < today) {
    return "overdue";
  }

  // 締め切り2営業日前（今日から2営業日以内）
  if (task.deadlineDate <= twoDaysLater) {
    return "upcoming";
  }

  // その他
  return "other";
}

// カテゴリ情報を取得（タイトル、アイコン）
function getCategoryInfo(category: TaskCategory): { title: string; icon: string } {
  switch (category) {
    case "completed":
      return { title: "対応済", icon: "✅" };
    case "overdue":
      return { title: "期日切れ", icon: "🚨" };
    case "upcoming":
      return { title: "締め切り2営業日前", icon: "⏰" };
    case "other":
      return { title: "その他", icon: "📋" };
  }
}

// 半角数字を全角数字に変換（等幅表示のため）
function toFullWidth(text: string): string {
  return text.replace(/[0-9]/g, (char) => {
    return String.fromCharCode(char.charCodeAt(0) + 0xfee0);
  });
}

export default function Command() {
  const [isLoading, setIsLoading] = useState(true);
  const [tasks, setTasks] = useState<Task[]>([]);
  const [today, setToday] = useState<Date>(new Date());
  const [twoDaysLater, setTwoDaysLater] = useState<Date>(new Date());

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
        const todayDate = new Date();
        todayDate.setHours(0, 0, 0, 0);
        setToday(todayDate);

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

        const twoDaysLaterDate = getBusinessDaysLater(todayDate, 2);
        setTwoDaysLater(twoDaysLaterDate);

        for (let i = DATA_START_ROW; i < values.length; i++) {
          const row = values[i];
          const status = row[myColumnIndex] || "";
          const title = row[2] || ""; // C列: 凡事徹底
          const deadline = row[3] || ""; // D列: 期日

          // 「対象外」以外のタスクを抽出（空文字列＝未着手、完了も含む）
          if (status !== "対象外" && title && deadline) {
            const deadlineDate = parseDeadline(deadline, todayDate);
            if (deadlineDate) {
              filteredTasks.push({
                rowIndex: i + 1,
                title,
                status: status || "未着手",
                deadline: formatDeadline(deadlineDate),
                columnIndex: myColumnIndex,
                deadlineDate,
              });
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

  // タスクをカテゴリ別に分類
  const categorizedTasks: Record<TaskCategory, Task[]> = {
    completed: [],
    overdue: [],
    upcoming: [],
    other: [],
  };

  tasks.forEach((task) => {
    const category = categorizeTask(task, today, twoDaysLater);
    categorizedTasks[category].push(task);
  });

  // カテゴリの表示順序
  const categoryOrder: TaskCategory[] = ["overdue", "upcoming", "completed", "other"];

  return (
    <List isLoading={isLoading}>
      {categoryOrder.map((category) => {
        const categoryTasks = categorizedTasks[category];
        const categoryInfo = getCategoryInfo(category);

        // セクションタイトル
        const sectionTitle = `${categoryInfo.icon}        ${categoryInfo.title}  ---`;

        return (
          <List.Section
            key={category}
            title={sectionTitle}
            subtitle={`${categoryTasks.length}件`}
          >
            {categoryTasks.length === 0 ? (
              <List.Item title="タスクはありません" icon="💤" />
            ) : (
              categoryTasks.map((task, index) => {
                const badge = getStatusBadge(task.status);
                // 期日を全角数字に変換（等幅表示）
                const fullWidthDeadline = toFullWidth(task.deadline);
                return (
                  <List.Item
                    key={`${category}-${index}`}
                    title={task.title}
                    accessories={[
                      { tag: { value: task.status, color: badge.color }, icon: badge.icon },
                      { text: fullWidthDeadline },
                    ]}
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
                );
              })
            )}
          </List.Section>
        );
      })}
    </List>
  );
}
