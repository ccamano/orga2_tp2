global Broken_alternativo_asm

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
; MENORES
aMenores:
db 4, 4, 0, 8, 0, 0, 0, 4, 0
db 0, 0, 4, 4, 0, 0, 0, 0, 16
db 0, 0, 32, 4, 8, 16, 16, 0, 8
db 32, 4, 4, 4, 0, 0, 0, 0, 0
db 4, 0, 4, 0, 4, 8, 0, 0, 4
db 0, 16, 0, 0, 32, 4, 8, 16, 8
db 0, 8, 0, 4, 4, 0, 0, 0, 4
db 0, 0, 8, 0, 4, 0, 4, 8, 0
db 0,4, 4, 16, 0, 0, 32, 4, 0
db 16, 8, 4, 8, 0, 16, 4, 0, 32
db 0, 4, 4, 0, 8, 0, 4, 0, 4
db 8, 0, 0, 4, 4, 0,0, 0, 0
db 4, 0, 0, 8, 4, 8, 0, 16, 0
db 0, 32, 4
; ULTIMOS
aMayores:
db 0,0, -4, 0, 0, 0, -4, 0, 0
db  0, -4, 0, 0, -8, 0, -4, -16, 0
db -4, 0, 0, 0, 0, 0, 0, 0, 0
db 0, 0, 0, 0, -4, 0, 0, 0, -4
db 0, 0, 0, -4, 0, 0, -8, 0, 0
db -16, 0, -4, 0, 0, 0, 0, 0, 0
db 0, 0, 0, 0, 0, -4, -4, 0, 0
db 0, -4, 0, 0, 0, -4, 0, 0, 0
db 0,0, 0, 0, -4, -4, 0, 0, -4
db 0, 0, 0, 0, 0,0, 0, -4, 0
db 0, 0, 0, -4, 0, 0, 0, -4, 0
db 0, 0, -4, 0, 0, -8, -4, -4, -16
db 0, -4, 0, 0, 0, 0, 0, 0, 0
db -4, 0, 0


mascara_a: times 4 db 0x00, 0x00, 0x00, 0xFF
mascara_r: times 4 db 0x00, 0x00, 0xFF, 0x00
mascara_gba: times 4 db 0xFF, 0xFF, 0x00, 0xFF
mascara_g: times 4 db 0x00, 0xFF, 0x00, 0x00
mascara_rba: times 4 db 0xFF, 0x00, 0xFF, 0xFF
mascara_b: times 4 db 0xFF, 0x00, 0x00, 0x00
mascara_rga: times 4 db 0x00, 0xFF, 0xFF, 0xFF

and_enteros: times 4 db 0xff
times 4 db 0x00

cuatros: times 4 dd 4
unos: times 4 dd 1

section .text

Broken_alternativo_asm:
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
  mov r9d, edx ; r9d = width <- columna

  mov r11d, r9d
  sub r11d, 32
  pxor xmm4, xmm4
  pinsrd xmm4, r11d, 00b     ; xmm4 = | 0 | 0 | 0 | width -32 |
  pshufd xmm4, xmm4, 0b     ; xmm4 = | width - 32  | width - 32  | width  - 32 | width - 32  |  
  movdqu xmm2, [cuatros]
  movdqa xmm8, xmm2
  pslld xmm8, 2              ; xmm8 = | 16 | (x4)
  movdqu xmm5, [unos]
  pcmpgtd xmm5, xmm4
  pand xmm5, xmm8
  paddd xmm4, xmm5
  

  mov r12, aModulo
  mov r13, 0
  
.cicloFilas:
  cmp ecx, r10d
  je .finCicloFilas


  mov edx, 0
  pmovsxbd xmm3, [r12 + r13 + 120] ; | ? | a_b | a_g | a_r |
  .cicloPrimerasColumnas:
    cmp edx, 16 ; los primeros 16 pixeles
    je .finCicloPrimerasColumnas
    
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
    jmp .cicloPrimerasColumnas

  .finCicloPrimerasColumnas:
    pmovsxbd xmm3, [r12 + r13] ; | ? | a_b | a_g | a_r |
    paddd xmm3, xmm8
    sub r9d, 32
  .cicloColumnasCentrales:
    cmp edx, r9d
    jge .finCicloColumnasCentrales
  
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
    movdqu xmm1, [rdi + r11 * 4]   ; los pixeles de los que tomamos la componente azul
    pand xmm1, xmm12    ;xmm12<- mascara azul
    pand xmm0, xmm15   ; pixeles que queremos cambiar sin la componente azul
    paddb xmm0, xmm1   ; la componente azul resuelta

    por xmm0, xmm9
    movdqu [rsi], xmm0

    lea rsi, [rsi + 16]
    paddd xmm3, xmm2
    add edx, 4
    jmp .cicloColumnasCentrales
  .finCicloColumnasCentrales:
    add r9d, 32
    pmovsxbd xmm3, [r12 + r13 + 240] ; | ? | a_b | a_g | a_r |
    paddd xmm3, xmm4
  .cicloColumnasFinales:
    cmp edx, r9d ; los ultimos 32 pixeles
    je .finCicloColumnas
  
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
    jmp .cicloColumnasFinales
  .finCicloColumnas:
  add r13, 3
  cmp r13, 120
  je .resetR13
  jmp .seguir
  .resetR13:
    mov r13, 0

  .seguir:
  lea rdi, [rdi + r8]
  inc ecx
  jmp .cicloFilas

.finCicloFilas:
  pop r13
  pop r12
  pop rbp
  ret