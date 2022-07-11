
#include <libgen.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "helper/imagenes.h"
#include "helper/libbmp.h"
#include "helper/tiempo.h"
#include "helper/utils.h"
#include "tp2.h"

// ~~~ seteo de los filtros ~~~

extern filtro_t Gamma;
extern filtro_t Gamma_lookup_table;
extern filtro_t Gamma_lookup_table_ymm;
extern filtro_t Max;
extern filtro_t Funny;
extern filtro_t Broken;
extern filtro_t Broken_alternativo;
extern filtro_t Broken_real_offset;

filtro_t filtros[8];

// ~~~ fin de seteo de filtros ~~~

int main(int argc, char** argv) {

  filtros[0] = Gamma;
  filtros[1] = Gamma_lookup_table;
  filtros[2] = Gamma_lookup_table_ymm;
  filtros[3] = Max;
  filtros[4] = Funny;
  filtros[5] = Broken;
  filtros[6] = Broken_alternativo;
  filtros[7] = Broken_real_offset;


  configuracion_t config;
  config.dst.width = 0;
  config.bits_src = 32;
  config.bits_dst = 32;

  procesar_opciones(argc, argv, &config);

  // Imprimo info
  if (!config.nombre) {
    printf("Procesando...\n");
    printf("  Filtro             : %s\n", config.nombre_filtro);
    printf("  Implementación     : %s\n", C_ASM((&config)));
    printf("  Archivo de entrada : %s\n", config.archivo_entrada);
  }

  snprintf(config.archivo_salida, sizeof(config.archivo_salida),
    "%s/%s.%s.%s%s.bmp", config.carpeta_salida,
    basename(config.archivo_entrada), config.nombre_filtro,
    C_ASM((&config)), config.extra_archivo_salida);

  if (config.nombre) {
    printf("%s\n", basename(config.archivo_salida));
    return 0;
  }

  filtro_t* filtro = detectar_filtro(&config);

  filtro->leer_params(&config, argc, argv);
  correr_filtro_imagen(&config, filtro->aplicador);
  filtro->liberar(&config);

  return 0;
}

filtro_t* detectar_filtro(configuracion_t* config) {
  for (int i = 0; filtros[i].nombre != 0; i++) {
    if (strcmp(config->nombre_filtro, filtros[i].nombre) == 0)
      return &filtros[i];
  }
  fprintf(stderr, "Filtro '%s' desconocido\n", config->nombre_filtro);
  exit(EXIT_FAILURE);
  return NULL;
}

void imprimir_tiempos_ejecucion(unsigned long long int cant_ciclos,
  int cant_iteraciones) {
  printf("Tiempo de ejecución:\n");
  printf("  # iteraciones                     : %d\n", cant_iteraciones);
  printf("  # de ciclos insumidos totales     : %llu\n", cant_ciclos);
  printf("  # de ciclos insumidos por llamada : %.4f\n",
    (double)cant_ciclos / (double)cant_iteraciones);
}

void correr_filtro_imagen(configuracion_t* config, aplicador_fn_t aplicador) {
  imagenes_abrir(config);

  unsigned long long start, end;

  imagenes_flipVertical(&config->src, src_img);
  imagenes_flipVertical(&config->dst, dst_img);
  if (config->archivo_entrada_2 != 0) {
    imagenes_flipVertical(&config->src_2, src_img2);
  }
  size_t* tiempos = malloc(config->cant_iteraciones * sizeof(unsigned long long));
  for (int i = 0; i < config->cant_iteraciones; i++) {
    MEDIR_TIEMPO_START(start)
      aplicador(config);
    MEDIR_TIEMPO_STOP(end)
      tiempos[i] = end - start;
  }
  imagenes_flipVertical(&config->dst, dst_img);

  imagenes_guardar(config);
  imagenes_liberar(config);

  for (int i = 0; i < config->cant_iteraciones - 1; i++) {
    printf("%ld,", tiempos[i]);
  }
  printf("%ld", tiempos[config->cant_iteraciones - 1]);
  printf("\n");
  free(tiempos);
}