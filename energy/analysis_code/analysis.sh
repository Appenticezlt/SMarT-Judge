#!/bin/bash

# 定义根目录（当前目录）
root_dir=$(pwd)

# 1. 在根目录下创建 energy 文件夹
mkdir -p "$root_dir/energy"

# 2. 遍历根目录下的其他文件夹
for dir in "$root_dir"/*/; do
  dir_name=$(basename "$dir")  # 获取文件夹名称
  
  # 跳过 energy 文件夹
  if [ "$dir_name" == "energy" ]; then
    continue
  fi
  
  # 3. 在 energy 文件夹下创建对应的子文件夹
  mkdir -p "$root_dir/energy/$dir_name"
  
  # 4. 查找子目录中的 conformation 文件夹
  conformation_dir="$dir/conformation"
  if [ -d "$conformation_dir" ]; then
    # 5. 将 conformation 文件夹中的 .xlsx 文件复制到 energy 文件夹下对应的子文件夹中
    cp "$conformation_dir"/*.xlsx "$root_dir/energy/$dir_name/"
  else
    echo "No conformation folder found in $dir"
  fi
done

echo "✅ Done!"
