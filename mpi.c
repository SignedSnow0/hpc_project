#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

void print_separator(int length) {
    printf("\n-");
    for (int i = 0; i < length; i++) {
        printf("-----");
    }
    printf("\n");
}

void print_matrix(int *matrix, int matrix_width, int matrix_height) {
    print_separator(matrix_width);
    for (int i = 0; i < matrix_height; i++) {
        printf("|");
        for (int j = 0; j < matrix_width; j++) {
            printf(" %02d |", matrix[i * matrix_width + j]);
        }

        print_separator(matrix_width);
    }
}

int smallest_multiple(int n, int x) {
    if (n % x == 0) {
        return n;
    }
    return n + (x - n % x);
}

int main(int argc, char **argv) {
    MPI_Init(&argc, &argv);

    // Argument parsing
    if (argc != 2) {
        fprintf(stderr, "Usage: %s matrix_size\n", argv[0]);
        return 1;
    }
    int matrix_width;
    if (sscanf(argv[1], "%u", &matrix_width) != 1) {
        fprintf(stderr, "Failed to parse the first argument as an integer\n");
        return 1;
    }

    int num_nodes, this_node;
    MPI_Comm_rank(MPI_COMM_WORLD, &this_node);
    MPI_Comm_size(MPI_COMM_WORLD, &num_nodes);

    int rows_per_node = (matrix_width + num_nodes - 1) / num_nodes;
    int matrix_height = smallest_multiple(matrix_width, rows_per_node);

    int local_matrix_width = matrix_width;
    int local_matrix_height = rows_per_node + 2;

    int *to_scatter;
    int *local_matrix =
        (int *)malloc(local_matrix_width * local_matrix_height * sizeof(int));

    if (this_node == 0) {
        srand(time(0));

        matrix_height += 2;
        int *matrix = (int *)malloc(matrix_height * matrix_width * sizeof(int));

        for (int i = 0; i < matrix_height; i++) {
            for (int j = 0; j < matrix_width; j++) {
                if (i == 0 || i > matrix_width) {
                    matrix[i * matrix_width + j] = -1;
                } else {
                    matrix[i * matrix_width + j] = rand() % 100;
                }
            }
        }

        int to_send_height = matrix_height + 2 * num_nodes - 2;
        to_scatter = (int *)malloc(to_send_height * matrix_width * sizeof(int));

        int j = 0;
        for (int i = 0; i < to_send_height; i += local_matrix_height) {
            memcpy(&to_scatter[i * matrix_width], &matrix[j * matrix_width],
                   (rows_per_node + 2) * matrix_width * sizeof(int));
            j += rows_per_node;
        }

        free(matrix);
    }

    MPI_Scatter(to_scatter, local_matrix_width * local_matrix_height, MPI_INT,
                local_matrix, local_matrix_width * local_matrix_height, MPI_INT,
                0, MPI_COMM_WORLD);
    if (this_node == 0) {
        free(to_scatter);
    }

    int *result_local_matrix = (int *)malloc(
        local_matrix_width * (local_matrix_height - 2) * sizeof(int));

    for (int i = 1; i < local_matrix_height - 1; i++) {
        for (int j = 0; j < local_matrix_width; j++) {
            float avg = 0;
            int avg_count = 0;
            for (int x = -1; x <= 1; x++) {
                for (int y = -1; y <= 1; y++) {
                    int x_coord = i + x;
                    int y_coord = j + y;

                    if (y_coord < 0 || y_coord >= local_matrix_width) {
                        continue;
                    }
                    int val =
                        local_matrix[x_coord * local_matrix_width + y_coord];
                    if (val == -1) {
                        continue;
                    }

                    avg += val;
                    avg_count++;
                }
            }
            avg /= avg_count;
            result_local_matrix[(i - 1) * local_matrix_width + j] =
                local_matrix[i * local_matrix_width + j] > avg;
        }
    }

    printf("Node %d", this_node);
    print_matrix(result_local_matrix, local_matrix_width,
                 local_matrix_height - 2);

    free(local_matrix);

    MPI_Finalize();

    return 0;
}
