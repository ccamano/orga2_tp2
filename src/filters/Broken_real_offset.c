#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <stdint.h>
#include "../tp2.h"

void Broken_real_offset_asm(uint8_t* src, uint8_t* dst, int width, int height,
    int src_row_size, int dst_row_size);

void Broken_real_offset_c(uint8_t* src, uint8_t* dst, int width, int height,
    int src_row_size, int dst_row_size);

typedef void (Broken_real_offset_fn_t)(uint8_t*, uint8_t*, int, int, int, int);


void leer_params_Broken_real_offset(configuracion_t* config, int argc, char* argv[]) {
}

void aplicar_Broken_real_offset(configuracion_t* config) {
    Broken_real_offset_fn_t* Broken_real_offset = SWITCH_C_ASM(config, Broken_real_offset_c, Broken_real_offset_asm);
    buffer_info_t info = config->src;
    Broken_real_offset(info.bytes, config->dst.bytes, info.width, info.height,
        info.row_size, config->dst.row_size);
}

void liberar_Broken_real_offset(configuracion_t* config) {

}

void ayuda_Broken_real_offset() {
    printf("       * Broken_real_offset\n");
    printf("           Ejemplo de uso : \n"
        "                         Broken_real_offset -i c facil.bmp\n");
}

DEFINIR_FILTRO(Broken_real_offset, 5)


