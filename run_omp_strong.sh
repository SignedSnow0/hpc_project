#!/bin/bash
#SBATCH --job-name=hpc_project_omp
#SBATCH --account=tra25_Inginfbo
#SBATCH --partition=g100_usr_prod
#SBATCH --mail-user=claudio.marchini@studio.unibo.it
#SBATCH -t 01:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH -o omp.out
#SBATCH -e omp.err
#SBATCH -c 48

sed -i 's/MATRIX_SIZE=[0-9]*/MATRIX_SIZE=4096/' omp.sh
echo "Running with matrix size: 4096" >> omp_strong.results

for i in {1..32}; do
    sed -i 's/#SBATCH -c [0-9]*/#SBATCH -c '"$i"'/' omp.sh
    sed -i 's/CORES=[0-9]*/CORES='"$i"'/' omp.sh
    sbatch omp.sh
    while [ $(squeue -u $USER | wc -l) -gt 1 ]; do
        sleep 1
    done
    cat omp.out >> omp_strong.results
done