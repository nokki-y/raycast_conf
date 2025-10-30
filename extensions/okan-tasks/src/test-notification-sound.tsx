import { showToast, Toast, getPreferenceValues, closeMainWindow } from "@raycast/api";
import { execSync } from "child_process";

interface Preferences {
  notificationSound?: string;
}

export default async function Command() {
  try {
    await closeMainWindow();

    const preferences = getPreferenceValues<Preferences>();
    const soundName = preferences.notificationSound || "Basso";

    // Æ¹Èå’á
    const title = "= åóÆ¹È";
    const message = `ş(n-š: ${soundName}`;

    // macOS·¹Æàå’áóØM	
    execSync(`osascript -e 'display notification "${message}" with title "${title}" sound name "${soundName}"'`);

    // RaycastnÈü¹È‚h:
    await showToast({
      style: Toast.Style.Success,
      title: "åóÆ¹ÈŒ†",
      message: `${soundName} nóLUŒ~W_`,
    });
  } catch (error) {
    console.error("åóÆ¹È¨éü:", error);
    await showToast({
      style: Toast.Style.Failure,
      title: "¨éü",
      message: "åónÆ¹Èk1WW~W_",
    });
  }
}
