#!/bin/bash

# 定义根目录
root_dir="."

# 查找根目录下的 traj_md.in 和 traj_RMSD.slurm 文件
files=$(find "$root_dir" -maxdepth 1 -type f \( -name "traj_md.in" -o -name "traj_MD.slurm" \))

# 检查是否找到文件
if [ -z "$files" ]; then
  echo "Error: No traj_md.in or traj_RMSD.slurm files found in $root_dir"
  exit 1
fi

# 遍历根目录下的所有子文件夹
for subfolder in "$root_dir"/*/; do
  # 获取子文件夹名称（去掉路径和末尾的斜杠）
  subfolder_name=$(basename "$subfolder")

  # 定义对应的 {文件夹名}_analysis 文件夹路径
  analysis_folder="${subfolder}/${subfolder_name}_analysis"

  # 如果目标文件夹不存在，则创建
  if [ ! -d "$analysis_folder" ]; then
    mkdir -p "$analysis_folder"
    echo "Created folder: $analysis_folder"
  fi

  # 复制文件到目标文件夹
  for file in $files; do
    cp "$file" "$analysis_folder/"
    echo "Copied $file to $analysis_folder"
  done
done
