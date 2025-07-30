#!/bin/bash

# 定义根目录
root_dir="."

# 遍历根目录下的所有文件夹
for folder in "$root_dir"/*/; do
  # 获取文件夹名称（去掉路径和末尾的斜杠）
  folder_name=$(basename "$folder")
  echo $folder_name
  # 进入当前文件夹
  cd "$folder" || continue
  pwd
  # 定义目标分析文件夹的路径
  analysis_folder="${folder_name}_analysis"

  # 检查分析文件夹是否存在，如果不存在则跳过
  if [ ! -d "$analysis_folder" ]; then
    echo "Analysis folder not found: $analysis_folder"
    continue
  fi

  # 识别 equil.rst 文件
  equil_rst_file="equil.rst"
  if [ ! -f "$equil_rst_file" ]; then
    echo "Error: $equil_rst_file not found in $folder"
    continue
  fi

  # 识别包含 solvated 的 prmtop 文件
  solvated_prmtop_file=$(find . -maxdepth 1 -type f -name "*solvated*.prmtop" | head -n 1)
  if [ -z "$solvated_prmtop_file" ]; then
    echo "Error: No solvated prmtop file found in $folder"
    continue
  fi

  # 复制 equil.rst 和 solvated.prmtop 文件到分析文件夹，保持文件名不变
  cp "$equil_rst_file" "$analysis_folder/"
  cp "$solvated_prmtop_file" "$analysis_folder/"

  echo "Copied $equil_rst_file and $solvated_prmtop_file to $analysis_folder (original names preserved)"

  cd - > /dev/null || continue
  pwd
done
