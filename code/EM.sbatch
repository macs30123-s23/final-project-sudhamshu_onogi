#!/bin/bash

#SBATCH --account=macs30123
#SBATCH --job-name=netEM   # job name
#SBATCH --output=netEM.out # output log file
#SBATCH --error=netEM.err  # error file
#SBATCH --time=36:00:00  # 1 hour of wall time
#SBATCH --nodes=1        # 1 GPU node
#SBATCH --ntasks=1       # 1 CPU core to drive GPU
#SBATCH --cpus-per-task=28
#SBATCH --mem=56G

module load R/4.2.0  

cd /home/sudhamshu/DASM
echo "job started at `date`"
Rscript iterate_em.R
echo "job finished at `date`"
