/// <reference types="@raycast/api">

/* 🚧 🚧 🚧
 * This file is auto-generated from the extension's manifest.
 * Do not modify manually. Instead, update the `package.json` file.
 * 🚧 🚧 🚧 */

/* eslint-disable @typescript-eslint/ban-types */

type ExtensionPreferences = {
  /** スプレッドシートID - おかんスプレッドシートのID */
  "spreadsheetId": string,
  /** シート名 - タスクが記載されているシートの名前 */
  "sheetName": string,
  /** シートGID - シートのGID(URLのgid=の後の数字) */
  "sheetGid": string,
  /** あなたの名前 - スプレッドシートの列ヘッダーと完全一致させること */
  "myName": string,
  /** 通知間隔 - 通知を送る間隔（デフォルト: 1時間） */
  "notificationInterval": "15" | "30" | "60" | "120" | "240"
}

/** Preferences accessible in all the extension's commands */
declare type Preferences = ExtensionPreferences

declare namespace Preferences {
  /** Preferences accessible in the `check-okan-tasks` command */
  export type CheckOkanTasks = ExtensionPreferences & {}
  /** Preferences accessible in the `notify-okan-tasks` command */
  export type NotifyOkanTasks = ExtensionPreferences & {}
}

declare namespace Arguments {
  /** Arguments passed to the `check-okan-tasks` command */
  export type CheckOkanTasks = {}
  /** Arguments passed to the `notify-okan-tasks` command */
  export type NotifyOkanTasks = {}
}

