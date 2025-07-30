#!/bin/bash

#SBATCH --job-name=Conformation_extractnew
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
mkdir -p pdb1
# 运行 cpptraj 提取每 50 帧的构象并输出成 PDB
cpptraj -p $solvated_prmtop_file <<EOF
# 读取拓扑
parm $solvated_prmtop_file

# 抽取每隔 50 帧
trajin ../md_2.nc 1 last 50 


# 周期性映像并中心化蛋白
autoimage

# 写出多文件 PDB，每帧一个
trajout pdb1/conformation_first.pdb pdb multi

# 执行命令
run
quit
EOF

echo "所有构象已提取到 pdbs/ 目录"