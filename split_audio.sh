#!/bin/bash

# Spliting UNCHAPTERED audio into small audios, based on slience detection.

# input:  working dir contains long audio file
# output: working_dir/mp3s contains splited mp3 files

# 脚本版本信息
echo "Audio Splitter Script - Version v1.7"

# 检查是否提供了文件路径参数
if [ -z "$1" ]; then
  echo "请提供音频文件路径作为参数。"
  echo "用法: $0 /path/to/your/audiofile.mp3"
  exit 1
fi

# 获取输入文件路径和文件名
input_file="$1"
input_dir=$(dirname "$input_file")
input_basename=$(basename "$input_file" .mp3)
output_dir="$input_dir/mp3s"

# 创建 mp3s 文件夹（如果不存在）
mkdir -p "$output_dir"

# 使用 FFmpeg 分析静音片段并生成时间戳，确保输出为标准时间格式，且保留两位小数
ffmpeg -i "$input_file" -af silencedetect=noise=-40dB:d=1 -f null - 2>&1 | \
awk '/silence_start:/ {printf "start %.2f\n", $5} /silence_end:/ {printf "end %.2f\n", $5}' > silence_times.txt

# 初始化分割点
index=1
start_time=0

# 获取音频总时长并取整数
total_duration=$(ffprobe -i "$input_file" -show_entries format=duration -v quiet -of csv="p=0" | awk '{printf "%.0f", $1}')

# 读取 silence_times.txt 文件并生成分割的音频文件
while read type time; do
  echo "DEBUG: 读取到 $type 时间: $time"  # 调试信息

  # 处理每个静音的起点作为分割点
  if [[ "$type" == "start" ]]; then
    output_file="$output_dir/${input_basename}_part${index}.mp3"
    
    # 确保结束时间大于开始时间
    if (( $(echo "$time > $start_time" | bc -l) )); then
      echo "切割文件： $output_file, 从 $start_time 到 $time"  # 调试信息
      
      # 使用 FFmpeg 切割音频
      ffmpeg -y -i "$input_file" -ss "$start_time" -to "$time" -c copy "$output_file"
      
      # 检查 FFmpeg 命令是否成功执行
      if [ $? -ne 0 ]; then
        echo "FFmpeg 处理文件时出错：$output_file"
        exit 1
      fi
      
      # 更新起始时间为当前静音的结束时间，准备下一个片段
      start_time=$time
      index=$((index + 1))
    else
      echo "跳过无效时间段： 从 $start_time 到 $time"
    fi
  fi
done < silence_times.txt

# 最后一个片段，从最后一个静音的结束时间到音频文件的结束
output_file="$output_dir/${input_basename}_part${index}.mp3"
echo "切割文件： $output_file, 从 $start_time 到 $total_duration"  # 调试信息

# 切割最后一段
ffmpeg -y -i "$input_file" -ss "$start_time" -to "$total_duration" -c copy "$output_file"

# 清理临时文件
rm silence_times.txt

echo "音频文件已成功分割，片段保存在 $output_dir 文件夹中。"

# 验证步骤：检查输出文件总时长是否与原始文件时长相等（允许10秒误差）
echo "验证切割结果中..."
output_total_duration=0

# 遍历所有输出文件，累加时长并取整数
for file in "$output_dir"/*.mp3; do
  duration=$(ffprobe -i "$file" -show_entries format=duration -v quiet -of csv="p=0" | awk '{printf "%.0f", $1}')
  output_total_duration=$((output_total_duration + duration))
done

# 计算总时长差并验证
time_diff=$((total_duration - output_total_duration))
time_diff=${time_diff#-}  # 取绝对值

if [ "$time_diff" -le 10 ]; then
  echo "切割验证成功！"
else
  echo "切割验证失败！输出文件总时长与原始文件不匹配。"
  echo "原始文件时长: $total_duration 秒"
  echo "输出文件总时长: $output_total_duration 秒"
  echo "时间差: $time_diff 秒"
fi