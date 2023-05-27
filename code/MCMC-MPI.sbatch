#!/bin/bash

#SBATCH --account=macs30123
#SBATCH --job-name=mcmc-mpi  # job name
#SBATCH --output=mcmc.out # output log file
#SBATCH --error=mcmc.err  # error file
#SBATCH --time=36:00:00  # 1 hour of wall time
#SBATCH --nodes=1        # 1 GPU node
#SBATCH --ntasks=1       # 1 CPU core to drive GPU
#SBATCH --cpus-per-task=28
#SBATCH --mem=56G

module load R/4.2.0  
module load openmpi

cd /home/sudhamshu/project-macs30123
echo "job started at `date`"
mpirun -np 28 Rscript mcmc-mpi-second-stage.R
echo "job finished at `date`"
