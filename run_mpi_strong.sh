#!/bin/bash

for i in {1..32}; do
    sed -i 's/#SBATCH --nodes=[0-9]*/#SBATCH --nodes='"$i"'/' mpi.sh
    sbatch mpi.sh
    while [ $(squeue -u $USER | wc -l) -gt 1 ]; do
        sleep 1
    done
    cat mpi.out >> mpi_strong.results
done