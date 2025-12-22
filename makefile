clean:
	@rm -f sequential
	@rm -f mpi
	@rm -f omp

sequential: clean
	@gcc sequential.c -o sequential
	@echo "Sequential built"

mpi: clean
	@mpicc mpi.c -o mpi
	@echo "Mpi built"

omp: clean
	@gcc -fopenmp omp.c -o omp
	@echo "OpenMP built"

all: clean sequential mpi omp
