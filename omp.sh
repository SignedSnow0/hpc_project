#!/bin/bash
#SBATCH --job-name=hpc_project_omp
#SBATCH --account=tra25_Inginfbo
#SBATCH --partition=g100_usr_prod
#SBATCH -t 01:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH -o omp.out
#SBATCH -e omp.err
#SBATCH -c 1

MATRIX_SIZE=23170
CORES=1
srun omp ${MATRIX_SIZE} ${CORES}