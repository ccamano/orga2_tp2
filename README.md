# tp2-orga-2

## Compilar filtros adicionales

```bash
cd src/
```

```bash
./custom_build.sh
```

## Ver las notebooks en python de la experimentación

Es necesario tener instalado JupyterLab. <https://jupyterlab.readthedocs.io/en/stable/getting_started/installation.html>

```bash
cd src/
```

```bash
jupyter lab
```

## Ejemplos filtros adicionales

```bash
./build/tp2-custom Broken_alternativo -i c img/HardCandy.bmp
```

```bash
./build/tp2-custom Broken_real_offset -i c img/HardCandy.bmp
```

```bash
./build/tp2-custom Gamma_lookup_table -i asm img/HardCandy.bmp
```

```bash
./build/tp2-custom Gamma_lookup_table_ymm -i asm img/HardCandy.bmp
```
