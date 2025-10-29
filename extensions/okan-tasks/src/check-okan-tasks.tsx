import { List, showToast, Toast, getPreferenceValues } from "@raycast/api";
import React, { useEffect, useState } from "react";
import { getAuthClient } from "./google-auth";

interface Preferences {
  spreadsheetId: string;
  sheetName: string;
  sheetGid: string;
  myName: string;
}

export default function Command() {
  const [isLoading, setIsLoading] = useState(true);
  const [message, setMessage] = useState("初期化中...");

  useEffect(() => {
    async function test() {
      try {
        console.log("=== Step 1: コマンド起動 ===");
        setMessage("Step 1: コマンド起動");

        await showToast({
          style: Toast.Style.Success,
          title: "Step 1",
          message: "コマンドが起動しました",
        });

        console.log("=== Step 2: Preferences取得 ===");
        const preferences = getPreferenceValues<Preferences>();
        console.log("Preferences:", {
          spreadsheetId: preferences.spreadsheetId,
          sheetName: preferences.sheetName,
          myName: preferences.myName,
          sheetGid: preferences.sheetGid,
        });
        setMessage(`Step 2: Preferences取得完了 (${preferences.myName})`);

        await showToast({
          style: Toast.Style.Success,
          title: "Step 2",
          message: `設定を取得しました: ${preferences.myName}`,
        });

        console.log("=== Step 3: Google認証クライアント初期化 ===");
        const authClient = await getAuthClient();
        console.log("認証クライアント初期化完了");
        setMessage("Step 3: Google認証完了");

        await showToast({
          style: Toast.Style.Success,
          title: "Step 3",
          message: "Google認証が完了しました",
        });

        console.log("=== Step 4: 完了 ===");
        setMessage("Step 4: 完了");

        await showToast({
          style: Toast.Style.Success,
          title: "完了",
          message: "全てのステップが完了しました",
        });

        setIsLoading(false);
      } catch (err) {
        console.error("=== エラー発生 ===", err);
        setMessage(`エラー: ${err}`);
        await showToast({
          style: Toast.Style.Failure,
          title: "エラー",
          message: String(err),
        });
        setIsLoading(false);
      }
    }

    test();
  }, []);

  return (
    <List isLoading={isLoading}>
      <List.Item title={message} />
      <List.Item title="この画面が表示されていれば、基本的な動作は正常です" />
    </List>
  );
}
