#!/bin/bash
#SBATCH --job-name=hpc_project_mpi
#SBATCH --account=tra25_Inginfbo
#SBATCH --partition=g100_usr_prod
#SBATCH -t 01:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH -o mpi.out
#SBATCH -e mpi.err

module load autoload intelmpi

MATRIX_SIZE=23170
srun mpi ${MATRIX_SIZE}