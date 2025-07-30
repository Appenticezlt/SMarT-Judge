#!/usr/bin/env bash
set -euo pipefail

# 统一汇总目录
OUT_DIR="NACdistance"
mkdir -p "$OUT_DIR"

# 遍历每个一级子目录
for dir in */; do
  mod=${dir%/}
  echo "🔍 处理模块：${mod}"

  # 查找 *analysis* 子目录
  mapfile -t analysis_paths < <(find "$mod" -maxdepth 1 -type d -name "*analysis*")
  if [[ ${#analysis_paths[@]} -eq 0 ]]; then
    echo "  ⚠️ 无 *analysis* 子目录，跳过"
    continue
  fi

  # 创建对应的输出子目录
  dest_dir="${OUT_DIR}/${mod}"
  mkdir -p "$dest_dir"

  for analysis_dir in "${analysis_paths[@]}"; do
    echo "  📂 扫描 ${analysis_dir} 中的目标 .dat 文件"

    # 只找符合命名规范的文件
    mapfile -t dat_files < <(find "$analysis_dir" -maxdepth 1 -type f -name "distance_atom_1526_4625_md*.dat")

    if [[ ${#dat_files[@]} -eq 0 ]]; then
      echo "    ⚠️ 未找到符合 distance_atom_1526_4625_md*.dat 的文件"
      continue
    fi

    for f in "${dat_files[@]}"; do
      echo "    ✅ 复制 $(basename "$f") → ${dest_dir}/"
      cp "$f" "$dest_dir/"
    done
  done
done

echo "🎉 所有符合命名的 .dat 文件已汇总至 ${OUT_DIR}/"

