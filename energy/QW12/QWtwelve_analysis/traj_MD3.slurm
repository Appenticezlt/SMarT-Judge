#!/bin/bash
#SBATCH --job-name=CpptrajMD
#SBATCH -p 64c512g
#SBATCH --output=%j.out
#SBATCH --error=%j.err
#SBATCH -n 64
#SBATCH --ntasks-per-node=64

ulimit -l unlimited
ulimit -s unlimited

module purge
module load gcc/9.3.0

# 识别当前路径下唯一的 solvated.prmtop 文件
solvated_prmtop_file=$(find . -maxdepth 1 -type f -name "*solvated*.prmtop" | head -n 1)

# 检查是否找到 solvated.prmtop 文件
if [ -z "$solvated_prmtop_file" ]; then
  echo "Error: No solvated prmtop file found in the current directory."
  exit 1
fi
echo "$solvated_prmtop_file"

cpptraj.OMP -p "$solvated_prmtop_file"  -i traj_md3.in > traj_md.out # Run cpptraj analysis
