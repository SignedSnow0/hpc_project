#!/bin/bash

for i in {1..32}; do
    matrix_size=$(echo "scale=0; sqrt(4096 * 4096 * ${i})" | bc -l)
    echo "Running with matrix size: ${matrix_size}" >> mpi_weak.results

    sed -i 's/#SBATCH --nodes=[0-9]*/#SBATCH --nodes='"$i"'/' mpi.sh
    sed -i 's/MATRIX_SIZE=[0-9]*/MATRIX_SIZE='"$matrix_size"'/' mpi.sh
    sbatch mpi.sh
    while [ $(squeue -u $USER | wc -l) -gt 1 ]; do
        sleep 1
    done
    cat mpi.out >> mpi_weak.results
done

echo "Baselines" >> mpi_weak.results
sed -i 's/#SBATCH --nodes=[0-9]*/#SBATCH --nodes=1/' mpi.sh
for i in {1..32}; do
    matrix_size=$(echo "scale=0; sqrt(4096 * 4096 * ${i})" | bc -l)
    sed -i 's/MATRIX_SIZE=[0-9]*/MATRIX_SIZE='"$matrix_size"'/' mpi.sh
    sbatch mpi.sh
    while [ $(squeue -u $USER | wc -l) -gt 1 ]; do
        sleep 1
    done
    cat mpi.out >> mpi_weak.results
done