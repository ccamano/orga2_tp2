#include <libgen.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

int main() {

  for (size_t i = 0; i < 256; i++) {
    double res = sqrt(i * 255);
    printf("%f\n", res);
  }

  printf("{");
  for (size_t i = 0; i < 256; i++) {
    double res = sqrt(i * 255);
    printf("%d,", (int)res);
  }
  printf("}");


  return 0;
}