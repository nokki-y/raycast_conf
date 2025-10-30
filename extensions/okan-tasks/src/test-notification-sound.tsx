import { showToast, Toast, getPreferenceValues, closeMainWindow } from "@raycast/api";
import { execSync } from "child_process";

interface Preferences {
  notificationSound?: string;
  notificationStyle?: string;
}

export default async function Command() {
  try {
    await closeMainWindow();

    const preferences = getPreferenceValues<Preferences>();
    const soundName = preferences.notificationSound || "Basso";
    const notificationStyle = preferences.notificationStyle || "alert";

    const title = "Test Notification Sound";
    const message = `Current setting: ${soundName} (${notificationStyle})`;

    if (notificationStyle === "alert") {
      // macOS alert (no sound)
      execSync(`osascript -e 'display alert "${title}" message "${message}" buttons {"OK"} default button "OK"'`);
    } else {
      // macOS notification banner (with sound)
      execSync(`osascript -e 'display notification "${message}" with title "${title}" sound name "${soundName}"'`);
    }

    // Raycast toast
    await showToast({
      style: Toast.Style.Success,
      title: "Notification sound test completed",
      message: `${soundName} sound was played`,
    });
  } catch (error) {
    console.error("Notification sound test error:", error);
    await showToast({
      style: Toast.Style.Failure,
      title: "Error",
      message: "Failed to test notification sound",
    });
  }
}
