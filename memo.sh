#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title memo
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🤖
# @raycast.packageName create-memo
# @raycast.argument1 { "type": "text", "placeholder": "ファイル名を入力" }

# Documentation:
# @raycast.description メモを作成するコマンド
# @raycast.author nokki_y

FILE_PATH="/Users/yoshihide-unoki/Library/CloudStorage/GoogleDrive-unoki.yoshihide@lmi-partners.page/マイドライブ/00_working/01_docs/${1}"

cursor /Users/yoshihide-unoki/Library/CloudStorage/GoogleDrive-unoki.yoshihide@lmi-partners.page/マイドライブ/00_working/
/Users/yoshihide-unoki/Library/CloudStorage/GoogleDrive-unoki.yoshihide@lmi-partners.page/マイドライブ/00_working/00_bin/create_md_file.sh ${FILE_PATH}
