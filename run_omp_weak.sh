#!/bin/bash

#for i in {1..32}; do
#    matrix_size=$(echo "scale=0; sqrt(4096 * 4096 * ${i})" | bc -l)
#    echo "Running with matrix size: ${matrix_size}" >> omp_weak.results
#
#    sed -i 's/#SBATCH -c [0-9]*/#SBATCH -c '"$i"'/' omp.sh
#    sed -i 's/CORES=[0-9]*/CORES='"$i"'/' omp.sh
#    sed -i 's/MATRIX_SIZE=[0-9]*/MATRIX_SIZE='"$matrix_size"'/' omp.sh
#    sbatch omp.sh
#   while [ $(squeue -u $USER | wc -l) -gt 1 ]; do
#        sleep 1
#    done
#    cat omp.out >> omp_weak.results
#done

echo "Baselines" >> omp_weak.results
sed -i 's/#SBATCH -c [0-9]*/#SBATCH -c 1/' omp.sh
sed -i 's/CORES=[0-9]*/CORES=1/' omp.sh
for i in {1..32}; do
    matrix_size=$(echo "scale=0; sqrt(4096 * 4096 * ${i})" | bc -l)
    sed -i 's/MATRIX_SIZE=[0-9]*/MATRIX_SIZE='"$matrix_size"'/' omp.sh
    sbatch omp.sh
    while [ $(squeue -u $USER | wc -l) -gt 1 ]; do
        sleep 1
    done
    cat omp.out >> omp_weak.results
done