#!/bin/bash

# This script will clean remaning files after an app is being removed.

# 检查是否提供了应用程序名称
if [ -z "$1" ]; then
  echo "Usage: $0 <Application Name>"
  exit 1
fi

APP_NAME="$1"

# 定义残留文件和目录的路径
declare -a paths=(
  "~/Library/Application Support/$APP_NAME"
  "~/Library/Caches/$APP_NAME"
  "~/Library/Preferences/com.$APP_NAME.plist"
  "~/Library/Logs/$APP_NAME"
  "~/Library/Containers/com.$APP_NAME"
  "~/Library/Cookies/com.$APP_NAME.binarycookies"
  "/Library/Application Support/$APP_NAME"
  "/Library/Preferences/com.$APP_NAME.plist"
  "/Library/Logs/$APP_NAME"
)

# 删除残留文件和目录
for path in "${paths[@]}"; do
  if [ -e "$path" ]; then
    echo "Removing $path"
    rm -rf "$path"
  else
    echo "$path not found, skipping..."
  fi
done

echo "Cleanup completed for $APP_NAME."
