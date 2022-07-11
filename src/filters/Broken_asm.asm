global Broken_asm
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

Broken_asm:
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

  pxor xmm4, xmm4
  pinsrd xmm4, r9d, 00b     ; xmm4 = | 0 | 0 | 0 | width |
  pshufd xmm4, xmm4, 0b     ; xmm4 = | width | width | width | width |  
  movdqu xmm2, [cuatro]

  mov r12, aModulo
  mov r13, 0
  
.cicloFilas:
  cmp ecx, r10d
  je .finCicloFilas
  mov edx, 0
  pmovsxbd xmm3, [r12 + r13] ; | ? | a_b | a_g | a_r |

  .cicloColumnas:
    cmp edx, r9d
    je .finCicloColumnas

    pxor xmm5, xmm5    ; xmm5 = 0
    pcmpgtd xmm5, xmm3
    pand xmm5, xmm4
    paddd xmm3, xmm5
    movdqa xmm6, xmm3
    pcmpgtd xmm6, xmm4
    pand xmm6, xmm4
    psubd xmm3, xmm6  ; | ? | jb | jg | jr |
    movdqa xmm6, xmm3
    pcmpeqd xmm6, xmm4
    pand xmm6, xmm4
    psubd xmm3, xmm6  ; | ? | jb | jg | jr |

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
    jmp .cicloColumnas
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