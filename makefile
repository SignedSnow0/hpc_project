clean:
	-rm sequential
	-rm mpi

sequential: clean
	gcc sequential.c -o sequential

mpi: clean
	mpicc mpi.c -o mpi
