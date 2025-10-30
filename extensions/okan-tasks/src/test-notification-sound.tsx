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

    // ƹ���
    const title = "= ��ƹ�";
    const message = `�(n-�: ${soundName}`;

    // macOS��������M	
    execSync(`osascript -e 'display notification "${message}" with title "${title}" sound name "${soundName}"'`);

    // Raycastn���Ȃh:
    await showToast({
      style: Toast.Style.Success,
      title: "��ƹȌ�",
      message: `${soundName} n�L�U�~W_`,
    });
  } catch (error) {
    console.error("��ƹȨ��:", error);
    await showToast({
      style: Toast.Style.Failure,
      title: "���",
      message: "��nƹ�k1WW~W_",
    });
  }
}
