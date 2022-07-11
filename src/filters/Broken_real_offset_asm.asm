global Broken_real_offset_asm
;j menor a 16
;j mayor a width-32
;j en el medio 
section .rodata

aModulo:
; i = 0, 1, 2
db 4, 4, -4, 8, 0, 0, -4, 4, 0
; i = 3, 4, 5
db  0, -4, 4, 4, -8, 0, -4, -16, 16
; i = 6, 7, 8
db -4, 0, 32, 4, 8, 16, 16, 0, 8
; i= 9, 10, 11
db 32, 4, 4, 4, -4, 0, 0, 0, -4
;i= 12, 13, 14
db 4, 0, 4, -4, 4, 8, -8, 0, 4
;i=15, 16, 17
db -16, 16, -4, 0, 32, 4, 8, 16, 8
;i=18, 19, 20
db 0, 8, 0, 4, 4, -4, -4, 0, 4
;i=21, 22, 23
db 0, -4, 8, 0, 4, -4, 4, 8, 0
;i=24, 25, 26
db 0,4, 4, 16, -4, -4, 32, 4, -4
;i=27, 28, 29
db 16, 8, 4, 8, 0, 16, 4, -4, 32
;i=30, 31, 32
db 0, 4, 4, -4, 8, 0, 4, -4, 4
;i=33, 34, 35
db 8, 0, -4, 4, 4, -8, -4, -4, -16
;i=36, 37, 38
db 4, -4, 0, 8, 4, 8, 0, 16, 0
;i=39
db -4, 32, 4

mascara_r: times 4 db 0x00, 0x00, 0xFF, 0x00
mascara_gba: times 4 db 0xFF, 0xFF, 0x00, 0xFF
mascara_g: times 4 db 0x00, 0xFF, 0x00, 0x00
mascara_rba: times 4 db 0xFF, 0x00, 0xFF, 0xFF
mascara_b: times 4 db 0xFF, 0x00, 0x00, 0x00
mascara_rga: times 4 db 0x00, 0xFF, 0xFF, 0xFF
mascara_a: times 4 db 0x00, 0x00, 0x00, 0xFF

and_enteros: times 4 db 0xff
times 4 db 0x00

cuatro: times 4 dd 4

section .text

Broken_real_offset_asm:
  push rbp
  mov rbp, rsp
  push r12
  push r13
; rdi = uint8_t *src
; rsi = uint8_t *dst
; edx = int width
; ecx = int height
; r8d = int src_row_size
; r9d = int dst_row_size

  movdqu xmm9, [mascara_a]
  movdqu xmm10, [mascara_r]
  movdqu xmm11, [mascara_g]
  movdqu xmm12, [mascara_b]
  movdqu xmm13, [mascara_gba]
  movdqu xmm14, [mascara_rba]
  movdqu xmm15, [mascara_rga]

  and r8, [and_enteros]
  
  mov r10d, ecx ; r10d = height <- fila
  mov ecx, 0
  xor r9, r9
  mov r9d, edx ; r9d = width <- columna

  movdqu xmm2, [cuatro]

  mov r12, aModulo
  mov r13, 0

  movdqu xmm0, [rdi]
  por xmm0, xmm9
  movdqu [rsi], xmm0
  lea rsi, [rsi + 16]

  pmovsxbd xmm3, [r12 + r13] ; | ? | a_b | a_g | a_r |
  paddd xmm3, xmm2
  mov edx, 4
  .cicloPrimeraFila:
    cmp edx, r9d
    je .finCicloPrimeraFila

    pextrd r11d, xmm3, 00b
    ; r11 tenemos edx + a[..], r
    movdqu xmm1, [rdi + r11 * 4]   ; los pixeles de los que tomamos la componente roja
    pand xmm1, xmm10
    pand xmm0, xmm13   ; pixeles que queremos cambiar sin la componente roja
    paddb xmm0, xmm1   ; la componente roja resuelta

    pextrd r11d, xmm3, 01b
    ; r11 tenemos edx + a[..], g
    movdqu xmm1, [rdi + r11 * 4]   ; los pixeles de los que tomamos la componente verde
    pand xmm1, xmm11    ;xmm12<- mascara verde
    pand xmm0, xmm14   ; pixeles que queremos cambiar sin la componente verde
    paddb xmm0, xmm1   ; la componente verde resuelta

    pextrd r11d, xmm3, 10b
    ; r11 tenemos edx + a[..], b
    movdqu xmm1, [rdi + r11 * 4]   ; los pixeles de los que tomamos la componente azul
    pand xmm1, xmm12    ;xmm12<- mascara azul
    pand xmm0, xmm15   ; pixeles que queremos cambiar sin la componente azul
    paddb xmm0, xmm1   ; la componente azul resuelta

    por xmm0, xmm9
    movdqu [rsi], xmm0

    lea rsi, [rsi + 16]
    paddd xmm3, xmm2
    add edx, 4
    jmp .cicloPrimeraFila
.finCicloPrimeraFila:
  lea rdi, [rdi + r8]
  add r13, 3

  
  sub r10d, 2
.cicloFilas:
  cmp ecx, r10d
  je .finCicloFilas
  mov edx, 0
  pmovsxbd xmm3, [r12 + r13] ; | ? | a_b | a_g | a_r |
  .cicloColumnas:
    cmp edx, r9d
    je .finCicloColumnas

    pextrd r11d, xmm3, 00b
    movsxd r11, r11d
    ; r11 tenemos edx + a[..], r
    movdqu xmm1, [rdi + r11 * 4]   ; los pixeles de los que tomamos la componente roja
    pand xmm1, xmm10
    pand xmm0, xmm13   ; pixeles que queremos cambiar sin la componente roja
    paddb xmm0, xmm1   ; la componente roja resuelta

    pextrd r11d, xmm3, 01b
    movsxd r11, r11d
    ; r11 tenemos edx + a[..], g
    movdqu xmm1, [rdi + r11 * 4]   ; los pixeles de los que tomamos la componente verde
    pand xmm1, xmm11    ;xmm12<- mascara verde
    pand xmm0, xmm14   ; pixeles que queremos cambiar sin la componente verde
    paddb xmm0, xmm1   ; la componente verde resuelta

    pextrd r11d, xmm3, 10b
    movsxd r11, r11d
    ; r11 tenemos edx + a[..], b
    movdqu xmm1, [rdi + r11 * 4]   ; los pixeles de los que tomamos la componente azul
    pand xmm1, xmm12    ;xmm12<- mascara azul
    pand xmm0, xmm15   ; pixeles que queremos cambiar sin la componente azul
    paddb xmm0, xmm1   ; la componente azul resuelta

    por xmm0, xmm9
    movdqu [rsi], xmm0

    lea rsi, [rsi + 16]
    paddd xmm3, xmm2
    add edx, 4
    jmp .cicloColumnas
  .finCicloColumnas:
  add r13, 3
  cmp r13, 120
  je .resetR13
  jmp .seguir
  .resetR13:
    mov r13, 0

  .seguir:
  pmovsxbd xmm3, [r12 + r13] ; | ? | a_b | a_g | a_r |
  lea rdi, [rdi + r8]
  inc ecx
  jmp .cicloFilas

.finCicloFilas:

  ; PROCESAMOS LA ULTIMA FILA
  mov edx, 0
  sub r9d, 32
.cicloUltimaFila:
    cmp edx, r9d
    je .finCicloUltimaFila

    pextrd r11d, xmm3, 00b
    ; r11 tenemos edx + a[..], r
    movsxd r11, r11d
    movdqu xmm1, [rdi + r11 * 4]   ; los pixeles de los que tomamos la componente roja
    pand xmm1, xmm10
    pand xmm0, xmm13   ; pixeles que queremos cambiar sin la componente roja
    paddb xmm0, xmm1   ; la componente roja resuelta

    pextrd r11d, xmm3, 01b
    movsxd r11, r11d
    ; r11 tenemos edx + a[..], g
    movdqu xmm1, [rdi + r11 * 4]   ; los pixeles de los que tomamos la componente verde
    pand xmm1, xmm11    ;xmm12<- mascara verde
    pand xmm0, xmm14   ; pixeles que queremos cambiar sin la componente verde
    paddb xmm0, xmm1   ; la componente verde resuelta

    pextrd r11d, xmm3, 10b
    movsxd r11, r11d
    ; r11 tenemos edx + a[..], b
    movdqu xmm1, [rdi + r11 * 4]   ; los pixeles de los que tomamos la componente azul
    pand xmm1, xmm12    ;xmm12<- mascara azul
    pand xmm0, xmm15   ; pixeles que queremos cambiar sin la componente azul
    paddb xmm0, xmm1   ; la componente azul resuelta

    por xmm0, xmm9
    movdqu [rsi], xmm0

    lea rsi, [rsi + 16]
    paddd xmm3, xmm2
    add edx, 4
    jmp .cicloUltimaFila
.finCicloUltimaFila:
  ; nos queda procesar los ultimos 32
  lea rdi, [rdi + r9 * 4]
  mov edx, 0
  .cicloUltimos32:
    cmp edx, 32
    je .fin
    movdqu xmm0, [rdi]
    por xmm0, xmm9
    movdqu [rsi], xmm0
    lea rdi, [rdi + 16]
    lea rsi, [rsi + 16]
  
    add edx, 4
    jmp .cicloUltimos32
  
.fin:
  pop r13
  pop r12
  pop rbp
  ret