clean:
	-rm sequential
	-rm mpi
	-rm omp

sequential: clean
	gcc sequential.c -o sequential

mpi: clean
	mpicc mpi.c -o mpi

omp: clean
	gcc -fopenmp omp.c -o omp
