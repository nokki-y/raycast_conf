import { google } from "googleapis";
import * as fs from "fs";
import * as path from "path";
import * as readline from "readline";

const SCOPES = ["https://www.googleapis.com/auth/spreadsheets.readonly"];
const AUTH_DIR = path.join(__dirname, "..", "assets", ".auth");
const TOKEN_PATH = path.join(AUTH_DIR, "token.json");
const CREDENTIALS_PATH = path.join(AUTH_DIR, "credentials.json");

async function authorize() {
  // 認証情報を読み込む
  if (!fs.existsSync(CREDENTIALS_PATH)) {
    console.error(`❌ 認証情報ファイルが見つかりません: ${CREDENTIALS_PATH}`);
    console.log(`\n📝 次の手順を実行してください:`);
    console.log(`1. Google Cloud Consoleからダウンロードした credentials.json を以下に配置:`);
    console.log(`   ${CREDENTIALS_PATH}`);
    console.log(`\n2. ディレクトリを作成:`);
    console.log(`   mkdir -p ${path.dirname(CREDENTIALS_PATH)}`);
    process.exit(1);
  }

  const credentials = JSON.parse(fs.readFileSync(CREDENTIALS_PATH, "utf8"));
  const { client_secret, client_id, redirect_uris } = credentials.installed || credentials.web;

  const oAuth2Client = new google.auth.OAuth2(client_id, client_secret, redirect_uris[0]);

  // 認証URLを生成
  const authUrl = oAuth2Client.generateAuthUrl({
    access_type: "offline",
    scope: SCOPES,
  });

  console.log("\n🔐 Google Sheets APIの認証を行います");
  console.log("\n以下のURLをブラウザで開いてください:");
  console.log(authUrl);

  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
  });

  rl.question("\n認証コードを入力してください: ", async (code) => {
    rl.close();

    try {
      const { tokens } = await oAuth2Client.getToken(code);
      oAuth2Client.setCredentials(tokens);

      // トークンを保存
      const dir = path.dirname(TOKEN_PATH);
      if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir, { recursive: true });
      }
      fs.writeFileSync(TOKEN_PATH, JSON.stringify(tokens, null, 2));

      console.log("\n✅ 認証が完了しました!");
      console.log(`トークンを保存しました: ${TOKEN_PATH}`);
      console.log("\n📋 次のステップ:");
      console.log("1. npm run dev を実行して拡張機能を起動");
      console.log("2. Raycastで 'Check Okan Tasks' を検索");
      console.log("3. 拡張機能の設定を行う (Spreadsheet ID, Sheet Name, My Name など)");
      console.log("\n✨ トークンは自動的にリフレッシュされます。手動更新は不要です。");
    } catch (error) {
      console.error("\n❌ 認証に失敗しました:", error);
      process.exit(1);
    }
  });
}

authorize();
