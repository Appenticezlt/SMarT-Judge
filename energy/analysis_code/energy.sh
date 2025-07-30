#!/bin/bash
# 文件必须存在于根目录
REQUIRED_FILES=("bond.py" "energy.slurm")

# 检查根目录中是否存在必须文件
for file in "${REQUIRED_FILES[@]}"; do
  if [[ ! -f "$file" ]]; then
    echo "❌ 缺失文件：$file，脚本终止"
    exit 1
  fi
done

# 遍历所有一级子目录
for folder in */; do
  [[ -d "$folder" ]] || continue

  subdir="${folder%/}/conformation"
  echo "📂 处理子目录：$subdir"


  # 拷贝 bond.py 和 energy.slurm
  cp bond.py energy.slurm "$subdir/"

  # 进入 conformation 并提交作业
  pushd "$subdir" > /dev/null
  echo "🚀 提交 energy.slurm → 当前目录：$(pwd)"
  sbatch energy.slurm
  popd > /dev/null
done

echo "✅ 所有作业已提交完成。"

