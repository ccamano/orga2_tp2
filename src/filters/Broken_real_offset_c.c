#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <stdint.h>
#include "../tp2.h"
#include "../helper/utils.h"

void Broken_real_offset_c(
    uint8_t* src,
    uint8_t* dst,
    int width,
    int height,
    int src_row_size,
    int dst_row_size) {
    bgra_t(*src_matrix)[(src_row_size + 3) / 4] = (bgra_t(*)[(src_row_size + 3) / 4]) src;
    bgra_t(*dst_matrix)[(dst_row_size + 3) / 4] = (bgra_t(*)[(dst_row_size + 3) / 4]) dst;

    int32_t a[40] = {0,-4,4,8,4,-4,4,8,0,-4,4,8,-4,0,4,-4,-4,4,16,32,4,0,4,-4,-8,-16,0,8,0,4,-4,0,0,4,0,16,32,16,8,4};

    for (int i = 0; i < height; i++) {
        for (int j = 0; j < width; j++) {
            int jr = j + a[(i + 10) % 40];
            int jg = j + a[(i + 20) % 40];
            int jb = j + a[(i + 30) % 40];
            if (i == 0 && j < 4) {
                // if (jr >= 0) dst_matrix[i][j].r = src_matrix[i][jr].r;
                dst_matrix[i][j].r = src_matrix[i][j].r;

                // if (jg >= 0) dst_matrix[i][j].g = src_matrix[i][jg].g;
                dst_matrix[i][j].g = src_matrix[i][j].g;

                // if (jb >= 0) dst_matrix[i][j].b = src_matrix[i][jb].b;
                dst_matrix[i][j].b = src_matrix[i][j].b;
            } else if (i == height - 1 && j >= width - 32) {
                // if (jr < width) dst_matrix[i][j].r = src_matrix[i][jr].r;
                dst_matrix[i][j].r = src_matrix[i][j].r;

                // if (jg < width) dst_matrix[i][j].g = src_matrix[i][jg].g;
                dst_matrix[i][j].g = src_matrix[i][j].g;

                // if (jb < width) dst_matrix[i][j].b = src_matrix[i][jb].b;
                dst_matrix[i][j].b = src_matrix[i][j].b;
            } else {
                dst_matrix[i][j].r = src_matrix[i][jr].r;
                dst_matrix[i][j].g = src_matrix[i][jg].g;
                dst_matrix[i][j].b = src_matrix[i][jb].b;
            }
        }
    }

}
