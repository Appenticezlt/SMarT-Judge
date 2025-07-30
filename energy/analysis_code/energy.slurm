#!/bin/bash

#SBATCH --job-name=energy
#SBATCH -p 64c512g
#SBATCH --output=%j.out
#SBATCH --error=%j.err
#SBATCH -n 64
#SBATCH --ntasks-per-node=64

ulimit -l unlimited
ulimit -s unlimited

module purge

python bond.py