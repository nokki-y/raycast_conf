import { getPreferenceValues, LocalStorage, environment } from "@raycast/api";
import { getSpreadsheetValues } from "./sheets-api";
import { execSync } from "child_process";
import * as fs from "fs";
import * as path from "path";

interface Preferences {
  spreadsheetId: string;
  sheetName: string;
  sheetGid: string;
  myName: string;
  notificationInterval?: string;
}

// 通知ロックファイルのパス
const LOCK_FILE_PATH = path.join(environment.supportPath, ".notification-lock");

// 通知ロックを取得（既にロックされている場合はfalseを返す）
function acquireNotificationLock(): boolean {
  try {
    console.log(`[ロック] パス: ${LOCK_FILE_PATH}`);

    // supportPathディレクトリが存在しない場合は作成
    if (!fs.existsSync(environment.supportPath)) {
      console.log(`[ロック] supportPathディレクトリを作成: ${environment.supportPath}`);
      fs.mkdirSync(environment.supportPath, { recursive: true });
    }

    // ロックファイルが存在するかチェック
    if (fs.existsSync(LOCK_FILE_PATH)) {
      console.log("[ロック] 既存のロックファイルを検出");
      // ロックファイルの作成時刻を確認（古いロックの場合は削除）
      const stats = fs.statSync(LOCK_FILE_PATH);
      const lockAge = Date.now() - stats.mtimeMs;
      const LOCK_TIMEOUT = 2 * 60 * 1000; // 2分でタイムアウト（Raycastのタイムアウトは54秒なので、余裕を持たせて2分）

      if (lockAge > LOCK_TIMEOUT) {
        console.log(`[ロック] タイムアウト（${lockAge}ms経過）- 削除して新規取得`);
        // 古いロックは削除して新規取得
        fs.unlinkSync(LOCK_FILE_PATH);
      } else {
        console.log(`[ロック] 有効なロックが存在（${lockAge}ms経過）- スキップ`);
        // 有効なロックが存在する
        return false;
      }
    }

    // ロックファイルを作成
    console.log("[ロック] ロックファイルを作成");
    fs.writeFileSync(LOCK_FILE_PATH, new Date().toISOString());
    return true;
  } catch (error) {
    console.error("ロック取得エラー:", error);
    return false;
  }
}

// 通知ロックを解放
function releaseNotificationLock(): void {
  try {
    if (fs.existsSync(LOCK_FILE_PATH)) {
      console.log("[ロック] ロックファイルを削除");
      fs.unlinkSync(LOCK_FILE_PATH);
    } else {
      console.log("[ロック] ロックファイルが既に存在しない");
    }
  } catch (error) {
    console.error("ロック解放エラー:", error);
  }
}

interface Task {
  title: string;
  status: string;
  deadline: string;
  deadlineDate: Date;
}

export default async function Command() {
  try {
    // 通知ロックを取得（既に通知が表示されている場合はスキップ）
    if (!acquireNotificationLock()) {
      console.log("通知ダイアログが既に表示されているため、スキップします");
      return;
    }

    const preferences = getPreferenceValues<Preferences>();
    const now = new Date();

    // 通知間隔チェック
    const notificationIntervalMinutes = parseInt(preferences.notificationInterval || "60", 10);
    const lastNotificationTime = await LocalStorage.getItem<string>("lastNotificationTime");
    console.log(`[間隔] 通知間隔: ${notificationIntervalMinutes}分`);
    console.log(`[間隔] 最後の通知時刻: ${lastNotificationTime || "なし"}`);

    if (lastNotificationTime) {
      const lastTime = new Date(lastNotificationTime);
      const minutesSinceLastNotification = (now.getTime() - lastTime.getTime()) / 1000 / 60;
      console.log(`[間隔] 経過時間: ${minutesSinceLastNotification.toFixed(2)}分`);

      if (minutesSinceLastNotification < notificationIntervalMinutes) {
        // まだ間隔時間が経過していない
        console.log(`[間隔] まだ間隔時間が経過していないためスキップ`);
        releaseNotificationLock();
        return;
      }
    }

    console.log(`[間隔] 間隔チェック通過 - データ取得開始`);

    // データ取得
    const range = `${preferences.sheetName}`;
    const values = await getSpreadsheetValues(preferences.spreadsheetId, range);

    if (values.length === 0) {
      releaseNotificationLock();
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
      releaseNotificationLock();
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

      if (overdueTasks.length > 0) {
        messages.push(`期日切れ: ${overdueTasks.length}件`);
        title = "🚨 期日切れタスクがあります！";
      }
      if (todayTasks.length > 0) {
        messages.push(`今日締切: ${todayTasks.length}件`);
        if (!title) {
          title = "⏰ 今日締切のタスクがあります！";
        }
      }

      const message = `${messages.join(" / ")}\n\nRaycastで「Check Okan Tasks」を開いてください`;

      try {
        console.log("[通知] macOSアラートを表示開始");
        // macOSアラートを表示（ユーザーが閉じるまで表示され続ける、音なし）
        const result = execSync(
          `osascript -e 'display alert "${title}" message "${message}" buttons {"OK", "タスクを確認"} default button "タスクを確認"'`
        ).toString();
        console.log(`[通知] ユーザーがボタンを押しました: ${result.trim()}`);

        // 「タスクを確認」ボタンが押された場合、Raycastでタスク一覧を開く
        if (result.includes("タスクを確認")) {
          console.log("[通知] タスク一覧を開きます");
          // Raycast URLスキームを使用してコマンドを直接開く
          execSync(`open "raycast://extensions/nokki-y/raycast-okan/check-okan-tasks"`);
        }

        // 最後の通知時刻を記録
        console.log("[通知] 最後の通知時刻を記録");
        await LocalStorage.setItem("lastNotificationTime", now.toISOString());
        console.log("[通知] try句終了 - finally句に移動");
      } finally {
        // 通知ダイアログが閉じられたらロックを解放
        console.log("[通知] finally句実行 - ロック解放開始");
        releaseNotificationLock();
        console.log("[通知] finally句完了");
      }
    } else {
      // タスクがない場合もロックを解放
      releaseNotificationLock();
    }
  } catch (error) {
    console.error("通知エラー:", error);
    // エラー時もロックを解放
    releaseNotificationLock();
  }
}
