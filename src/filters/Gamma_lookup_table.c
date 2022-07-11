#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <stdint.h>
#include "../tp2.h"

void Gamma_lookup_table_asm(uint8_t* src, uint8_t* dst, int width, int height,
    int src_row_size, int dst_row_size);

void Gamma_lookup_table_c(uint8_t* src, uint8_t* dst, int width, int height,
    int src_row_size, int dst_row_size);

typedef void (Gamma_lookup_table_fn_t)(uint8_t*, uint8_t*, int, int, int, int);


void leer_params_Gamma_lookup_table(configuracion_t* config, int argc, char* argv[]) {
}

void aplicar_Gamma_lookup_table(configuracion_t* config) {
    Gamma_lookup_table_fn_t* Gamma_lookup_table = SWITCH_C_ASM(config, Gamma_lookup_table_c, Gamma_lookup_table_asm);
    buffer_info_t info = config->src;
    Gamma_lookup_table(info.bytes, config->dst.bytes, info.width, info.height,
        info.row_size, config->dst.row_size);
}

void liberar_Gamma_lookup_table(configuracion_t* config) {

}

void ayuda_Gamma_lookup_table() {
    printf("       * Gamma_lookup_table\n");
    printf("           Ejemplo de uso : \n"
        "                         Gamma_lookup_table -i c facil.bmp\n");
}

DEFINIR_FILTRO(Gamma_lookup_table, 1)


