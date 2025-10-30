/**
 * Google Sheets APIを直接REST APIで呼び出す
 * googleapis ライブラリは重すぎるため、fetchを使用
 */

import { readFileSync, writeFileSync } from "fs";
import { join } from "path";
import { environment } from "@raycast/api";

interface TokenData {
  access_token: string;
  refresh_token: string;
  expiry_date: number;
  scope: string;
  token_type: string;
}

interface CredentialsData {
  installed: {
    client_id: string;
    client_secret: string;
    redirect_uris: string[];
  };
}

// トークンファイルのパスを取得
function getTokenPath(): string {
  return join(environment.assetsPath, ".auth/token.json");
}

// 認証情報ファイルのパスを取得
function getCredentialsPath(): string {
  return join(environment.assetsPath, ".auth/credentials.json");
}

// トークンをリフレッシュ
async function refreshAccessToken(tokenData: TokenData): Promise<TokenData> {
  try {
    const credentialsPath = getCredentialsPath();
    const credentialsData: CredentialsData = JSON.parse(readFileSync(credentialsPath, "utf-8"));
    const { client_id, client_secret } = credentialsData.installed;

    const response = await fetch("https://oauth2.googleapis.com/token", {
      method: "POST",
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: new URLSearchParams({
        client_id,
        client_secret,
        refresh_token: tokenData.refresh_token,
        grant_type: "refresh_token",
      }),
    });

    if (!response.ok) {
      throw new Error(`トークンのリフレッシュに失敗しました: ${response.status} ${response.statusText}`);
    }

    const data = (await response.json()) as {
      access_token: string;
      expires_in: number;
      token_type: string;
    };

    // 新しいトークンデータを作成（有効期限は現在時刻 + expires_in）
    const newTokenData: TokenData = {
      access_token: data.access_token,
      refresh_token: tokenData.refresh_token, // refresh_tokenは変わらない
      expiry_date: Date.now() + data.expires_in * 1000,
      scope: tokenData.scope,
      token_type: data.token_type,
    };

    // トークンファイルに保存
    const tokenPath = getTokenPath();
    writeFileSync(tokenPath, JSON.stringify(newTokenData, null, 2));

    return newTokenData;
  } catch (error) {
    throw new Error(`トークンのリフレッシュ中にエラーが発生しました: ${error}`);
  }
}

// auth/token.jsonからアクセストークンを読み込む（必要に応じて自動リフレッシュ）
async function getAccessToken(): Promise<string> {
  try {
    const tokenPath = getTokenPath();
    let tokenData: TokenData = JSON.parse(readFileSync(tokenPath, "utf-8"));

    // トークンの有効期限をチェック（5分前にリフレッシュ）
    const now = Date.now();
    const expiryThreshold = 5 * 60 * 1000; // 5分

    if (tokenData.expiry_date && now >= tokenData.expiry_date - expiryThreshold) {
      console.log("トークンの有効期限が近いため、リフレッシュします...");
      tokenData = await refreshAccessToken(tokenData);
      console.log("トークンをリフレッシュしました");
    }

    return tokenData.access_token;
  } catch (error) {
    throw new Error(
      `アクセストークンの読み込みに失敗しました。.auth/token.jsonが存在するか確認してください。パス: ${getTokenPath()}\nエラー: ${error}`
    );
  }
}

export async function getSpreadsheetValues(spreadsheetId: string, range: string): Promise<any[][]> {
  const url = `https://sheets.googleapis.com/v4/spreadsheets/${spreadsheetId}/values/${encodeURIComponent(range)}`;
  const accessToken = await getAccessToken();

  const response = await fetch(url, {
    headers: {
      "Authorization": `Bearer ${accessToken}`,
    },
  });

  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(
      `Sheets API エラー: ${response.status} ${response.statusText}\n` +
        `URL: ${url}\n` +
        `Range: ${range}\n` +
        `レスポンス: ${errorText}`
    );
  }

  const data = (await response.json()) as { values?: any[][] };
  return data.values || [];
}
