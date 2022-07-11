global Max_asm

section .rodata
mascara_rgb: times 4 db 0xFF, 0xFF, 0xFF, 0x00
mascara_a:   times 4 db 0x00, 0x00, 0x00, 0xFF
blanco: times 16 db 0xFF

max_word: times 8 dw 0xFFFF

pixel1: times 4 db 0xFF
times 12 db 0x00

pixel2: times 4 db 0x00
times 4 db 0xFF
times 8 db 0x00

pixel3: times 8 db 0x00
times 4 db 0xFF
times 4 db 0x00

pixel4: times 12 db 0x00
times 4 db 0xFF

parte_alta: times 8 db 0xFF
times 8 db 0x00

section .text
Max_asm:
; rdi = uint8_t *src
; rsi = uint8_t *dst
; edx = int width
; ecx = int height
; r8d = int src_row_size
; r9d = int dst_row_size
  push rbp
  mov rbp, rsp
  push r12
  push r13
  push r14
  push r15

  movdqu xmm10, [mascara_rgb]
  movdqu xmm11, [mascara_a]

  ; maximo con phminpousw
  movdqu xmm12, [max_word]
  movdqu xmm13, [parte_alta]


  mov r12, rdi
  mov r13, rsi
  mov r15, pixel1

  mov r11, r13
  mov r10d, ecx ; height
  sub ecx, 2    ; height - 2
  mov r9d, edx 
  sub r9d, 2    ; width - 2

  xor rsi, rsi
  mov esi, r8d  ; esi = row_size

.cicloFilas:
  cmp ecx, 0
  je .finCicloFilas
  mov edx, r9d
  .cicloColumnas:
    cmp edx, 0
    je .finCicloColumnas

    lea rdi, [r12]
    call maximoSubmatriz

    pextrq [r13 + rsi + 4], xmm1, 0b
    pextrq [r13 + rsi * 2 + 4], xmm1, 0b

    lea r12, [r12 + 8]
    lea r13, [r13 + 8]
    sub edx, 2
    jmp .cicloColumnas
  .finCicloColumnas:
  lea r12, [r12 + rsi + 8]
  lea r13, [r13 + rsi + 8]
  sub ecx, 2
  jmp .cicloFilas

.finCicloFilas:
  mov rdi, r11
  mov esi, r9d        ; esi = width - 2
  add esi, 2          ; esi = width
  mov edx, r10d
  call bordeBlanco

  pop r15
  pop r14
  pop r13
  pop r12
  pop rbp
  ret

bordeBlanco:
  ; rdi = dst
  ; esi = int width
  ; edx = int height

  movdqu xmm0, [blanco]
  shr esi, 2              ; width / 4
  mov ecx, esi

.superior:
  movdqu [rdi], xmm0
  lea rdi, [rdi + 16]
  loop .superior

  lea rdi, [rdi - 4] ; rdi -> apunta al último pixel de la primera fila
  mov ecx, edx
  dec ecx            ; ecx = height - 1

  shl esi, 2             ; width
.laterales:                ; escribimos en el último pixel de una fila y en el primero de la siguiente
  pextrq [rdi], xmm0, 0b
  lea rdi, [rdi + rsi * 4] ; avanzamos a la proxima fila
  loop .laterales

  ; rdi apunta al último pixel de la última fila
  lea rdi, [rdi - 12]    ; retrocedemos 3 pixeles
  shr esi, 2             ; width / 4
  mov ecx, esi

.inferior:
  movdqu [rdi], xmm0
  lea rdi, [rdi - 16]
  loop .inferior

  ret

; rdi = uint8_t* src
; rsi = row_size
;
; xmm1 = pixel a usar (x4)
maximoSubmatriz:
  movdqu xmm1, [rdi] ; fila 1
  lea rdi, [rdi + rsi]
  movdqu xmm2, [rdi] ; fila 2
  call maximoFilas
  ; pixel maximo repetido 4 veces
  movdqa xmm0, xmm1

  lea rdi, [rdi + rsi]
  movdqu xmm1, [rdi] ; fila 3
  lea rdi, [rdi + rsi]
  movdqu xmm2, [rdi] ; fila 4
  call maximoFilas
  pblendw xmm0, xmm1, 1100b       ; xmm0[63:0] = maxFila3-4 | maxFila1-2

  pand xmm0, xmm10                ; xmm0[0:63] = | 0 | R1 | G1 | B1 | 0 | R0 | G0 | B0 |
  pmovzxbw xmm1, xmm0             ; xmm1 = |   0    |    R1   |   G1   |    B1   |   0    |    R0   |   G0   |    B0   |

  ; Yi = Ri + Gi + Bi
  phaddw xmm1, xmm1               ; xmm1 = | R1 + 0 | G1 + B1 | R0 + 0 | G0 + B0 | (x2)
  phaddw xmm1, xmm1               ; xmm1 = | Y1 | Y0 | (x4)
  movdqa xmm2, xmm1               ; xmm2 = | Y1 | Y0 | Y1 | Y0 | Y1 | Y0 | Y1 | Y0 |
  pslldq xmm1, 2                  ; xmm1 = | Y0 | Y1 | Y0 | Y1 | Y0 | Y1 | Y0 | 0  |

  pcmpgtw xmm2, xmm1              ; xmm2[16:31] = 0xffff si Y1 > Y0, 0 si no
  psrad xmm2, 16                  ; xmm2[0:31] = 0xffffffff si Y1 > Y0, 0 si no
  movdqa xmm1, xmm2               ; xmm1[0:31] = 0xffffffff si Y1 > Y0, 0 si no
  pslldq xmm2, 4
  ; xmm2[32:63] = 0xffffffff si Y1 > Y0, 0 si no
  ; xmm2[0:31] = 0x0
  movdqa xmm3, xmm0               ; xmm3[0:63] = | 0 | R1 | G1 | B1 | 0 | R0 | G0 | B0 |
  pand xmm3, xmm2
  ; xmm3[0:31]  = 0
  ; xmm3[32:63] = | 0 | R1 | G1 | B1 | si Y1 > Y0
  pandn xmm1, xmm0
  ; xmm1[0:31]  = | 0 | R0 | G0 | B0 | si Y0 >= Y1, 0 si no
  pblendw xmm1, xmm3, 1100b
  ; xmm1[0:31]  = | 0 | R0 | G0 | B0 | si Y0 >= Y1, 0 si no
  ; xmm3[32:63] = | 0 | R1 | G1 | B1 | si Y1 > Y0
  pand xmm1, xmm13

  phaddd xmm1, xmm1
  phaddd xmm1, xmm1 ; el pixel que suma el maximo 4 veces

  ; reseteamos la transparencia a 255
  por xmm1, xmm11

  ret

; xmm1 = primera fila
; xmm2 = segunda fila
maximoFilas:
  movdqa xmm4, xmm1                
  pand xmm4, xmm10                ; xmm4 = | 0 | R3 | G3 | B3 | 0 | R2 | G2 | B2 | 0 | R1 | G1 | B1 | 0 | R0 | G0 | B0 |
  pmovzxbw xmm3, xmm4             ; xmm3 = |   0    |    R1   |   G1   |    B1   |   0    |    R0   |   G0   |    B0   |
  psrldq xmm4, 8                  ; xmm4 = |                  0                  | 0 | R3 | G3 | B3 | 0 | R2 | G2 | B2 |
  pmovzxbw xmm4, xmm4             ; xmm4 = |   0    |    R3   |   G3   |    B3   |   0    |    R2   |   G2   |    B2   |

  ; Yi = Ri + Gi + Bi
  phaddw xmm3, xmm3               ; xmm3 = | R1 + 0 | G1 + B1 | R0 + 0 | G0 + B0 | (x2)
  phaddw xmm3, xmm3               ; xmm3 = | Y1     | Y0      | (x4)
  phaddw xmm4, xmm4               ; xmm4 = | R3 + 0 | G3 + B3 | R2 + 0 | G2 + B2 | (x2)
  phaddw xmm4, xmm4               ; xmm4 = | Y3     | Y2      | (x4)

  movdqa xmm6, xmm2                
  pand xmm6, xmm10                ; xmm6 = | 0 | R7 | G7 | B7 | 0 | R6 | G6 | B6 | 0 | R5 | G5 | B5 | 0 | R4 | G4 | B4 |
  pmovzxbw xmm5, xmm6             ; xmm5 = |   0    |    R5   |   G5   |    B5   |   0    |    R4   |   G4   |    B4   |
  psrldq xmm6, 8                  ; xmm6 = |                  0                  | 0 | R7 | G7 | B7 | 0 | R6 | G6 | B6 |
  pmovzxbw xmm6, xmm6             ; xmm6 = |   0    |    R7   |   G7   |    B7   |   0    |    R6   |   G6   |    B6   |

  ; Yi = Ri + Gi + Bi
  phaddw xmm5, xmm5               ; xmm5 = | R5 + 0 | G5 + B5 | R4 + 0 | G4 + B4 | (x2)
  phaddw xmm5, xmm5               ; xmm5 = | Y5     | Y4      | (x4)
  phaddw xmm6, xmm6               ; xmm6 = | R7 + 0 | G7 + B7 | R6 + 0 | G6 + B6 | (x2)
  phaddw xmm6, xmm6               ; xmm6 = | Y7     | Y6      | (x4)

  pblendw xmm3, xmm4, 11001100b   ; xmm3 = | Y3 | Y2 | Y1 | Y0 | Y3 | Y2 | Y1 | Y0 |
  pblendw xmm5, xmm6, 11001100b   ; xmm5 = | Y7 | Y6 | Y5 | Y4 | Y7 | Y6 | Y5 | Y4 |
  pblendw xmm3, xmm5, 11110000b   ; xmm3 = | Y7 | Y6 | Y5 | Y4 | Y3 | Y2 | Y1 | Y0 |

  movdqa xmm4, xmm12
  psubw xmm4, xmm3                ; xmm4 = | 2^(16) - 1 - Y7 | 2^(16) - 1 - Y6 | 2^(16) - 1 - Y5 | 2^(16) - 1 - Y4 | 2^(16) - 1 - Y3 | 2^(16) - 1 - Y2 | 2^(16) - 1 - Y1 | 2^(16) - 1 - Y0 |

  phminposuw xmm3, xmm4           ; xmm3[16:18] = posMax
  pextrb r14, xmm3, 10b           ; r14[0:2] = posMax

  pslldq xmm3, 13                 ; xmm3[120:122] = posMax
  psllw xmm3, 5                  ; xmm3[125:127] = posMax
  psrad xmm3, 31                  ; xmm3[96:127] = 0xffffff si max en fila 2, 0x0 si max en fila 1

  pshufd xmm3, xmm3, 11111111b    ; xmm3 = | 0xffffff si max en fila 2, 0x0 si max en fila 1 | (x4)
  pand xmm2, xmm3                 ; xmm2 = fila2 si max en fila2, 0 si no
  pandn xmm3, xmm1                ; xmm3 = fila1 si max en fila1, 0 si no
  paddd xmm2, xmm3                ; xmm2 = fila con el maximo

  and r14, 11b
  shl r14, 4                      ; r14 * 16
  movdqu xmm1, [r15 + r14]

  pand xmm1, xmm2

  phaddd xmm1, xmm1
  phaddd xmm1, xmm1            ; xmm1 = | Xmax | (x4)

  ret