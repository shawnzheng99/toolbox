#!/bin/bash

# Concating audios into a long random audio.

# input:  working dir splited mp3 files.
# output: a new long randomly concated audio file & faded_files contains audio files with faded effect.

# This script will
# 1. take mp3s directory path as param
# 2. add fade in and out to each mp3 and store them into faded_files
# 3. create a random list of faded mp3s
# 4. create a new long audio based on random list

# exceptions: if 2 is done, this script will start from 3.

# if a_output.mp3 has fade at the start, use below cmd:
# trim 5 secs off: ffmpeg -i input.mp4 -ss 5 -c copy output_trimmed.mp4


echo "Audio Processing Script - Version 1.7"

if [ -z "$1" ]; then
  echo "请提供包含 MP3 文件的目录路径作为参数。"
  echo "用法: $0 /path/to/directory"
  exit 1
fi

input_dir="$1"

faded_dir="$input_dir/faded_mp3s"

input_mp3_count=$(find "$input_dir" -maxdepth 1 -name "*.mp3" ! -name "a_output.mp3" | wc -l)
faded_mp3_count=$(find "$faded_dir" -name "*.mp3" 2>/dev/null | wc -l)

if [ -d "$faded_dir" ] && [ "$faded_mp3_count" -eq "$input_mp3_count" ]; then
  echo "faded_files 文件夹已存在且文件数量匹配，跳过 Step 1。"
else
  echo "处理 Step 1：添加淡入淡出效果..."

  if [ -d "$faded_dir" ]; then
    rm -rf "$faded_dir"/*
  else
    mkdir -p "$faded_dir"  
  fi

  for file in "$input_dir"/*.mp3; do
    if [[ $(basename "$file") == "a_output.mp3" ]]; then
      continue
    fi

    duration=$(ffprobe -i "$file" -show_entries format=duration -v quiet -of csv="p=0")

    ffmpeg -i "$file" -af "afade=in:st=0:d=0.2,afade=out:st=$(echo "$duration - 0.2" | bc):d=0.2" "$faded_dir/fade_$(basename "$file")"
  done
fi

echo "创建随机顺序的 file_list.txt 文件..."
find "$faded_dir" -name "*.mp3" | awk 'BEGIN{srand()} {print $0, rand()}' | sort -k2 | awk '{print "file \x27" $1 "\x27"}' > "$input_dir/file_list.txt"

if [ ! -s "$input_dir/file_list.txt" ]; then
  echo "错误：file_list.txt 文件为空，可能未找到要拼接的文件。"
  exit 1
fi

output_file="$input_dir/a_output.mp3"

echo "拼接所有文件到 $output_file..."
ffmpeg -y -f concat -safe 0 -i "$input_dir/file_list.txt" -c copy "$output_file"

echo "拼接完成，输出文件为 $output_file"
