import { showToast, Toast, getPreferenceValues, LaunchType, launchCommand, showHUD, LocalStorage, environment } from "@raycast/api";
import { getSpreadsheetValues } from "./sheets-api";
import { execSync } from "child_process";

interface Preferences {
  spreadsheetId: string;
  sheetName: string;
  sheetGid: string;
  myName: string;
  notificationInterval?: string;
}

// 通知間隔からチェック頻度を算出（システム負荷を考慮）
function calculateCheckInterval(notificationIntervalMinutes: number): number {
  // 通知間隔が1時間以下の場合は、同じ間隔でチェック
  if (notificationIntervalMinutes <= 60) {
    return notificationIntervalMinutes;
  }
  // 通知間隔が1時間を超える場合は、チェック頻度を1時間に固定
  // （システム負荷を抑えつつ、再起動検出も機能させる）
  return 60;
}

interface Task {
  title: string;
  status: string;
  deadline: string;
  deadlineDate: Date;
}

export default async function Command() {
  try {
    const preferences = getPreferenceValues<Preferences>();
    const now = new Date();

    // 通知間隔から最適なチェック間隔を算出
    const notificationIntervalMinutes = parseInt(preferences.notificationInterval || "60", 10);
    const checkIntervalMinutes = calculateCheckInterval(notificationIntervalMinutes);
    // 再起動検出の閾値: チェック間隔の1.5倍
    const restartDetectionThreshold = checkIntervalMinutes * 1.5;
    const lastNotificationTime = await LocalStorage.getItem<string>("lastNotificationTime");
    const lastCheckTime = await LocalStorage.getItem<string>("lastCheckTime");

    // 最後のチェック時刻を更新
    await LocalStorage.setItem("lastCheckTime", now.toISOString());

    // 前回のチェック時刻がない、または閾値以上経過している場合は再起動と判断
    if (!lastCheckTime) {
      // 初回起動 → タイマーをリセット
      await LocalStorage.removeItem("lastNotificationTime");
    } else {
      const lastCheck = new Date(lastCheckTime);
      const minutesSinceLastCheck = (now.getTime() - lastCheck.getTime()) / 1000 / 60;

      // 閾値以上経過している場合はRaycastが再起動されたと判断してリセット
      if (minutesSinceLastCheck >= restartDetectionThreshold) {
        await LocalStorage.removeItem("lastNotificationTime");
      }
    }

    // 通常の間隔チェック
    if (lastNotificationTime) {
      const lastTime = new Date(lastNotificationTime);
      const minutesSinceLastNotification = (now.getTime() - lastTime.getTime()) / 1000 / 60;

      if (minutesSinceLastNotification < notificationIntervalMinutes) {
        // まだ間隔時間が経過していない
        return;
      }
    }

    // データ取得
    const range = `${preferences.sheetName}`;
    const values = await getSpreadsheetValues(preferences.spreadsheetId, range);

    if (values.length === 0) {
      return;
    }

    // 自分の列を特定
    const headers = values[0];
    let myColumnIndex = headers.findIndex((header: string) => header === preferences.myName);

    if (myColumnIndex === -1) {
      myColumnIndex = headers.findIndex((header: string) =>
        header && header.includes(preferences.myName.replace(/\s+/g, ""))
      );
    }

    if (myColumnIndex === -1) {
      const lastName = preferences.myName.split(/\s+/)[0];
      myColumnIndex = headers.findIndex((header: string) => header && header.includes(lastName));
    }

    if (myColumnIndex === -1) {
      return;
    }

    // 今日の日付
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const tasks: Task[] = [];
    const DATA_START_ROW = 4;

    // タスクを収集
    for (let i = DATA_START_ROW; i < values.length; i++) {
      const row = values[i];
      const status = row[myColumnIndex] || "";
      const title = row[2] || "";
      const deadline = row[3] || "";

      // 対象外とすでに完了したタスクはスキップ
      if (status === "対象外" || status === "完了" || !title || !deadline) {
        continue;
      }

      // 期日をパース
      const deadlineParts = deadline.match(/(\d+)\/(\d+)/);
      if (deadlineParts) {
        const month = parseInt(deadlineParts[1], 10);
        const day = parseInt(deadlineParts[2], 10);
        const deadlineDate = new Date(today.getFullYear(), month - 1, day);
        deadlineDate.setHours(0, 0, 0, 0);

        tasks.push({
          title,
          status,
          deadline,
          deadlineDate,
        });
      }
    }

    // 期日切れタスクと当日タスクをカウント
    const overdueTasks = tasks.filter((task) => task.deadlineDate < today);
    const todayTasks = tasks.filter((task) => task.deadlineDate.getTime() === today.getTime());

    // 期日切れまたは当日タスクがあれば通知
    if (overdueTasks.length > 0 || todayTasks.length > 0) {
      const messages: string[] = [];
      let title = "";
      let soundName = "Glass"; // デフォルトの音

      if (overdueTasks.length > 0) {
        messages.push(`期日切れ: ${overdueTasks.length}件`);
        title = "🚨 期日切れタスクがあります！";
        soundName = "Basso"; // より目立つ音
      }
      if (todayTasks.length > 0) {
        messages.push(`今日締切: ${todayTasks.length}件`);
        if (!title) {
          title = "⏰ 今日締切のタスクがあります！";
        }
      }

      const message = `${messages.join(" / ")} - Raycastで「Check Okan Tasks」を開いてください`;

      // macOSシステム通知を送信（音付き）
      execSync(`osascript -e 'display notification "${message}" with title "${title}" sound name "${soundName}"'`);

      // Raycastのトーストも表示
      await showToast({
        style: Toast.Style.Failure,
        title: title,
        message: messages.join(" / "),
        primaryAction: {
          title: "📋 今すぐタスクを確認",
          onAction: async () => {
            await launchCommand({ name: "check-okan-tasks", type: LaunchType.UserInitiated });
          },
        },
      });

      // 最後の通知時刻を記録
      await LocalStorage.setItem("lastNotificationTime", now.toISOString());
    }
  } catch (error) {
    console.error("通知エラー:", error);
    // エラーは静かに無視（バックグラウンドコマンドなので）
  }
}
