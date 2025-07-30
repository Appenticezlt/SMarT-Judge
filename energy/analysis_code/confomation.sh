#!/usr/bin/env bash
set -euo pipefail

# 根目录下的 slurm 脚本
SLURM_SCRIPTS=(conform1.slurm conform2.slurm conform3.slurm)

# 检查脚本是否都存在
for script in "${SLURM_SCRIPTS[@]}"; do
  if [[ ! -f "$script" ]]; then
    echo "ERROR: 找不到根目录下的 $script"
    exit 1
  fi
done

# 遍历所有一级子目录
for dir in */; do
  # 只处理目录
  [[ -d "$dir" ]] || continue

  echo "== 处理子目录: $dir =="

  # 进入子目录
  pushd "$dir" > /dev/null

  # 在当前子目录中找第一个匹配 *solvated*.prmtop 的文件
  solvated_prmtop_file=$(find . -maxdepth 1 -type f -name "*solvated*.prmtop" | head -n 1)
  if [[ -z "$solvated_prmtop_file" ]]; then
    echo "  WARNING: 在 $dir 中未找到 *solvated*.prmtop，跳过"
    popd > /dev/null
    continue
  fi

  echo "  找到拓扑文件: $solvated_prmtop_file"

  # 创建 conformation 目录
  mkdir -p conformation

  # 拷贝 prmtop 文件
  cp "$solvated_prmtop_file" conformation/

  # 拷贝根目录下的 slurm 脚本
  for script in "${SLURM_SCRIPTS[@]}"; do
    cp "../$script" conformation/
  done

  # 进入 conformation，提交作业
  pushd conformation > /dev/null
  for script in "${SLURM_SCRIPTS[@]}"; do
    echo "    sbatch $script"
    sbatch "$script"
  done
  popd > /dev/null

  # 返回根目录
  popd > /dev/null
done

echo "全部子目录处理完毕。"

