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
if [ -z "$solvated_prmtop_file" ]; then
  echo "Error: No solvated prmtop file found in the current directory."
  exit 1
fi
echo "Using topology: $solvated_prmtop_file"

# 轨迹编号列表（根据需要修改或生成）
for n in 1 2 3 4; do
  inname="traj_md${n}.in"
  outdat="distance_atom_O_C_md${n}.dat"
  outlog="traj_md${n}.out"

  cat > "$inname" <<EOF
trajin ../md_${n}.nc
reference ../equil.rst
strip :WAT,Cl-,Na+
distance dist_atom_1526_4620 @1526 @4620 out $outdat
run
quit
EOF

  echo "Running cpptraj for md_${n}.nc → $outdat"
  cpptraj.OMP -p "$solvated_prmtop_file" -i "$inname" > "$outlog" &
done

# 等待所有后台任务完成
wait
echo "All cpptraj tasks finished."
