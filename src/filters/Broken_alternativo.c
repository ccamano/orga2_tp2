#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <stdint.h>
#include "../tp2.h"

void Broken_alternativo_asm(uint8_t* src, uint8_t* dst, int width, int height,
    int src_row_size, int dst_row_size);

void Broken_alternativo_c(uint8_t* src, uint8_t* dst, int width, int height,
    int src_row_size, int dst_row_size);

typedef void (Broken_alternativo_fn_t)(uint8_t*, uint8_t*, int, int, int, int);


void leer_params_Broken_alternativo(configuracion_t* config, int argc, char* argv[]) {
}

void aplicar_Broken_alternativo(configuracion_t* config) {
    Broken_alternativo_fn_t* Broken_alternativo = SWITCH_C_ASM(config, Broken_alternativo_c, Broken_alternativo_asm);
    buffer_info_t info = config->src;
    Broken_alternativo(info.bytes, config->dst.bytes, info.width, info.height,
        info.row_size, config->dst.row_size);
}

void liberar_Broken_alternativo(configuracion_t* config) {

}

void ayuda_Broken_alternativo() {
    printf("       * Broken_alternativo\n");
    printf("           Ejemplo de uso : \n"
        "                         Broken_alternativo -i c facil.bmp\n");
}

DEFINIR_FILTRO(Broken_alternativo, 5)


