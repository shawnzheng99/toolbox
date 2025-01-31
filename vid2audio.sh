#!/bin/bash

# Converting mp4 to mp3

# input:  working dir with mp4.
# output: a long mp3


if [ -z "$1" ]; then
  echo "请提供文件夹路径作为参数。"
  echo "用法: $0 /path/to/your/video/folder"
  exit 1
fi

cd "$1" || { echo "无法访问指定的文件夹路径: $1"; exit 1; }

mkdir -p mp3s

for file in *.mp4; do

  if [ -e "$file" ]; then
    ffmpeg -i "$file" -vn -ab 160k -ac 2 "mp3s/${file%.mp4}.mp3"
  else
    echo "没有找到任何 .mp4 文件。"
    exit 1
  fi
done

echo "所有文件已成功转换，并保存到 mp3s 文件夹中。"