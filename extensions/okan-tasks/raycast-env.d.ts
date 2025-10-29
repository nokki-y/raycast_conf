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
  "myName": string
}

/** Preferences accessible in all the extension's commands */
declare type Preferences = ExtensionPreferences

declare namespace Preferences {
  /** Preferences accessible in the `check-okan-tasks-test` command */
  export type CheckOkanTasksTest = ExtensionPreferences & {}
  /** Preferences accessible in the `check-okan-tasks` command */
  export type CheckOkanTasks = ExtensionPreferences & {}
}

declare namespace Arguments {
  /** Arguments passed to the `check-okan-tasks-test` command */
  export type CheckOkanTasksTest = {}
  /** Arguments passed to the `check-okan-tasks` command */
  export type CheckOkanTasks = {}
}

