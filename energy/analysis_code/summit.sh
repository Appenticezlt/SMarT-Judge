#!/usr/bin/env bash
set -euo pipefail

SLURM_SCRIPT="traj.slurm"

if [[ ! -f "$SLURM_SCRIPT" ]]; then
  echo "❌ 未找到 ${SLURM_SCRIPT}，请确认在根目录下运行"
  exit 1
fi

# 遍历一级子目录
for dir in */; do
  folder="${dir%/}"
  echo "🔍 检查目录：${folder}"

  # 在该子目录中查找名称包含 analysis 的文件夹
  mapfile -t analysis_paths < <(find "$folder" -maxdepth 1 -type d -name "*analysis*")
  if [[ ${#analysis_paths[@]} -eq 0 ]]; then
    echo "  ⚠️ 没有匹配 '*analysis*' 的子文件夹，跳过"
    continue
  fi

  # 对每个匹配的 analysis 目录进行操作
  for analysis_dir in "${analysis_paths[@]}"; do
    echo "  📂 处理 ${analysis_dir}"
    cp "$SLURM_SCRIPT" "$analysis_dir/"
    pushd "$analysis_dir" > /dev/null
      echo "    ➜ sbatch ${SLURM_SCRIPT}"
      sbatch "${SLURM_SCRIPT}"
    popd > /dev/null
  done
done

echo "✅ 全部提交完毕。"
