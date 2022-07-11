#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <stdint.h>
#include "../tp2.h"
#include "../helper/utils.h"

void Broken_alternativo_c(
    uint8_t* src,
    uint8_t* dst,
    int width,
    int height,
    int src_row_size,
    int dst_row_size) {
    bgra_t(*src_matrix)[(src_row_size + 3) / 4] = (bgra_t(*)[(src_row_size + 3) / 4]) src;
    bgra_t(*dst_matrix)[(dst_row_size + 3) / 4] = (bgra_t(*)[(dst_row_size + 3) / 4]) dst;

    int32_t a[40] = {0,-4,4,8,4,-4,4,8,0,-4,4,8,-4,0,4,-4,-4,4,16,32,4,0,4,-4,-8,-16,0,8,0,4,-4,0,0,4,0,16,32,16,8,4};
    int32_t aMenores[40] = {0,0,4,8,4,0,4,8,0,0,4,8,0,0,4,0,0,4,16,32,4,0,4,0,0,0,0,8,0,4,0,0,0,4,0,16,32,16,8,4};
    int32_t aMayores[40] = {0,-4,0,0,0,-4,0,0,0,-4,0,0,-4,0,0,-4,-4,0,0,0,0,0,0,-4,-8,-16,0,0,0,0,-4,0,0,0,0,0,0,0,0,0};
    // v1:
    // int32_t aMenores[40] = {0,4,4,8,4,4,4,8,0,4,4,8,4,0,4,4,0,4,16,32,4,0,4,4,8,0,0,8,0,4,4,0,0,4,0,16,32,16,8,4};
    // int32_t aMayores16_0[40] = {0,-4,0,-4,0,-4,0,-8,0,-4,0,0,-4,-16,0,-4,-4,0,0,-8,0,-4,0,-4,-8,-16,0,8,0,0,-4,0,-8,0,-4,0,0,0,-16,0};


    // int32_t aMayores32_16[40] = {0,-4,4,8,4,-4,4,8,0,-4,4,8,-4,0,4,-4,-4,4,16,16,4,0,4,-4,-8,-16,0,8,0,4,-4,0,0,4,0,16,8,16,8,4};
    // int32_t aMayores16_0[40] = {0,-4,0,0,0,-4,0,0,0,-4,0,0,-4,0,0,-4,-4,0,0,0,0,0,0,-4,-8,-16,0,8,0,0,-4,0,0,0,0,0,0,0,0,0};


    for (int i = 0; i < height; i++) {
        for (int j = 0; j < width; j++) {
            if (j < 16) {
                dst_matrix[i][j].r = src_matrix[i][(j + aMenores[(i + 10) % 40])].r;
                dst_matrix[i][j].g = src_matrix[i][(j + aMenores[(i + 20) % 40])].g;
                dst_matrix[i][j].b = src_matrix[i][(j + aMenores[(i + 30) % 40])].b;
            }
            // else if (j >= width - 16) {
            //     dst_matrix[i][j].r = src_matrix[i][(j + aMayores16_0[(i + 10) % 40])].r;
            //     dst_matrix[i][j].g = src_matrix[i][(j + aMayores16_0[(i + 20) % 40])].g;
            //     dst_matrix[i][j].b = src_matrix[i][(j + aMayores16_0[(i + 30) % 40])].b;
            // } 
            else if (j >= width - 32) {
                dst_matrix[i][j].r = src_matrix[i][(j + aMayores[(i + 10) % 40])].r;
                dst_matrix[i][j].g = src_matrix[i][(j + aMayores[(i + 20) % 40])].g;
                dst_matrix[i][j].b = src_matrix[i][(j + aMayores[(i + 30) % 40])].b;
            } else {
                dst_matrix[i][j].r = src_matrix[i][(j + a[(i + 10) % 40])].r;
                dst_matrix[i][j].g = src_matrix[i][(j + a[(i + 20) % 40])].g;
                dst_matrix[i][j].b = src_matrix[i][(j + a[(i + 30) % 40])].b;
            }
        }
    }
}
