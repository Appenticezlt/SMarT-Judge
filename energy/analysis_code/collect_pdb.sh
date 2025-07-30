#!/usr/bin/env bash
set -euo pipefail

# 创建总输出文件夹
OUT_DIR="pdb"
mkdir -p "$OUT_DIR"

# 遍历根目录下的一级子目录
for dir in */; do
  folder="${dir%/}"
  echo "🔍 处理目录：$folder"

  # 在该子目录下查找所有 .pdb 文件（只查一级）
  mapfile -t pdb_files < <(find "$folder" -maxdepth 1 -type f -name "*.pdb")

  if [[ ${#pdb_files[@]} -eq 0 ]]; then
    echo "  ⚠️ 没有 .pdb 文件，跳过"
    continue
  fi

  # 在目标 pdb 文件夹下创建对应子目录
  dest="${OUT_DIR}/${folder}"
  mkdir -p "$dest"

  for f in "${pdb_files[@]}"; do
    echo "  📄 复制 $(basename "$f") → $dest/"
    cp "$f" "$dest/"
  done
done

echo "✅ 所有 .pdb 文件已整理至 ${OUT_DIR}/ 下对应目录"

