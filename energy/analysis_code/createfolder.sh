#!/bin/bash

# 定义根目录
root_dir="."

# 遍历根目录下的所有文件夹
for folder in "$root_dir"/*/; do
  # 获取文件夹名称（去掉路径和末尾的斜杠）
  folder_name=$(basename "$folder")

  # 在文件夹内创建以 {文件夹名字}_analysis 命名的文件夹
  analysis_folder="${folder}/${folder_name}_analysis"
  mkdir -p "$analysis_folder"

  echo "Created folder: $analysis_folder"
done
