#include <omp.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

int main(int argc, char **argv) {
    // Argument parsing
    if (argc != 3) {
        fprintf(stderr, "Usage: %s matrix_size num_threads\n", argv[0]);
        return 1;
    }
    uint32_t matrix_size, n_threads;
    if (sscanf(argv[1], "%u", &matrix_size) != 1) {
        fprintf(stderr, "Failed to parse first argument as an integer\n");
        return 1;
    }
    if (sscanf(argv[2], "%u", &n_threads) != 1) {
        fprintf(stderr, "Failed to parse second argument as an integer\n");
        return 1;
    }

    double start = omp_get_wtime();

    // Matrix initialization
    srand(time(NULL));
    uint32_t *matrix_a =
        (uint32_t *)malloc(sizeof(uint32_t) * matrix_size * matrix_size);
    uint32_t *matrix_t =
        (uint32_t *)malloc(sizeof(uint32_t) * matrix_size * matrix_size);
    for (uint32_t i = 0; i < matrix_size; i++) {
        for (uint32_t j = 0; j < matrix_size; j++) {
            matrix_a[i * matrix_size + j] = rand() % 100;
        }
    }

#pragma omp parallel num_threads(n_threads) shared(matrix_a, matrix_t, matrix_size)
#pragma omp for
    for (uint32_t i = 0; i < matrix_size; i++) {
        for (uint32_t j = 0; j < matrix_size; j++) {
            float avg = 0;
            uint32_t avg_count = 0;
            for (int32_t x = -1; x <= 1; x++) {
                for (int32_t y = -1; y <= 1; y++) {
                    int32_t x_coord = i + x;
                    int32_t y_coord = j + y;

                    if (x_coord < 0 || x_coord >= matrix_size || y_coord < 0 ||
                        y_coord >= matrix_size) {
                        continue;
                    }

                    avg += matrix_a[x_coord * matrix_size + y_coord];
                    avg_count++;
                }
            }
            avg /= avg_count;

            matrix_t[i * matrix_size + j] = matrix_a[i * matrix_size + j] > avg;
        }
    }
    double end = omp_get_wtime();
    double elapsed = (end - start) * 1000;

    printf("Threads: %u Time elapsed: %lf ms\n", n_threads, elapsed);

    return 0;
}
