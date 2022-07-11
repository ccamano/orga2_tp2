global Gamma_asm

section .rodata
ALIGN 16

mascara_transparencia: times 4 db 0x00, 0x00, 0x00, 0xFF

float255:  times 4 dd 255.0

section .text
Gamma_asm:
  ; rdi = uint8_t *src
  ; rsi = uint8_t *dst
  ; edx = int width
  ; ecx = int height
  ; r8d = int src_row_size
  ; r9d int dst_row_size
  push rbp
  mov rbp, rsp

  movdqu xmm11, [mascara_transparencia]
  movups xmm12, [float255]  ; xmm12 = | 255 | 255 | 255 | 255 | float
  sqrtps xmm12, xmm12       ; xmm12 = | sqrt(255) | sqrt(255) | sqrt(255) | sqrt(255) | float

  shr edx, 2 ; width / 4
.cicloFilas:
  cmp ecx, 0
  je .fin
  mov r8d, 0
.cicloColumnas:
  cmp r8d, edx
  je .finCicloColumnas  
  pmovzxbd xmm1, [rdi]    ; xmm0 = | P3 | P2 | P1 | P0 |
  pmovzxbd xmm2, [rdi+4] ; xmm1 = | A0 | R0 | G0 | B0 |
  pmovzxbd xmm3, [rdi+8] ; xmm2 = | A0 | R0 | G0 | B0 |
  pmovzxbd xmm4, [rdi+12] ; xmm3 = | A0 | R0 | G0 | B0 |
  cvtdq2ps xmm1, xmm1 ; xmm1 = | A0 | R0 | G0 | B0 | float
  cvtdq2ps xmm2, xmm2 ; xmm2 = | A1 | R1 | G1 | B1 | float
  cvtdq2ps xmm3, xmm3 ; xmm3 = | A2 | R2 | G2 | B2 | float
  cvtdq2ps xmm4, xmm4 ; xmm4 = | A3 | R3 | G3 | B3 | float
  
  sqrtps xmm1, xmm1     ; xmm1 = | sqrt(A0) | sqrt(R0) | sqrt(G0) | sqrt(B0) |
  sqrtps xmm2, xmm2     ; xmm2 = | sqrt(A1) | sqrt(R1) | sqrt(G1) | sqrt(B1) |
  sqrtps xmm3, xmm3     ; xmm3 = | sqrt(A2) | sqrt(R2) | sqrt(G2) | sqrt(B2) |
  sqrtps xmm4, xmm4     ; xmm4 = | sqrt(A3) | sqrt(R3) | sqrt(G3) | sqrt(B3) | 
  
  mulps xmm1, xmm12     ; xmm1 = | 255.0*(sqrt(A0/255.0)) | 255.0*(sqrt(R0/255.0)) | 255.0*(sqrt(G0/255.0)) | 255.0*(sqrt(B0/255.0)) |
  mulps xmm2, xmm12     ; xmm2 = | 255.0*(sqrt(A1/255.0)) | 255.0*(sqrt(R1/255.0)) | 255.0*(sqrt(G1/255.0)) | 255.0*(sqrt(B1/255.0)) |
  mulps xmm3, xmm12     ; xmm3 = | 255.0*(sqrt(A2/255.0)) | 255.0*(sqrt(R2/255.0)) | 255.0*(sqrt(G2/255.0)) | 255.0*(sqrt(B2/255.0)) |
  mulps xmm4, xmm12     ; xmm4 = | 255.0*(sqrt(A3/255.0)) | 255.0*(sqrt(R3/255.0)) | 255.0*(sqrt(G3/255.0)) | 255.0*(sqrt(B3/255.0)) |
  
  cvtps2dq xmm1, xmm1   ; xmm1 = | 255.0*(sqrt(A0/255.0)) | 255.0*(sqrt(R0/255.0)) | 255.0*(sqrt(G0/255.0)) | 255.0*(sqrt(B0/255.0)) | int
  cvtps2dq xmm2, xmm2   ; xmm2 = | 255.0*(sqrt(A1/255.0)) | 255.0*(sqrt(R1/255.0)) | 255.0*(sqrt(G1/255.0)) | 255.0*(sqrt(B1/255.0)) | int
  cvtps2dq xmm3, xmm3   ; xmm3 = | 255.0*(sqrt(A2/255.0)) | 255.0*(sqrt(R2/255.0)) | 255.0*(sqrt(G2/255.0)) | 255.0*(sqrt(B2/255.0)) | int
  cvtps2dq xmm4, xmm4   ; xmm4 = | 255.0*(sqrt(A3/255.0)) | 255.0*(sqrt(R3/255.0)) | 255.0*(sqrt(G3/255.0)) | 255.0*(sqrt(B3/255.0)) | int

  packusdw xmm1, xmm2   ; xmm1 = | 255.0*(sqrt(A1/255.0)) | 255.0*(sqrt(R1/255.0)) | 255.0*(sqrt(G1/255.0)) | 255.0*(sqrt(B1/255.0)) | 255.0*(sqrt(A0/255.0)) | 255.0*(sqrt(R0/255.0)) | 255.0*(sqrt(G0/255.0)) | 255.0*(sqrt(B0/255.0)) |
  packusdw xmm3, xmm4   ; xmm3 = | 255.0*(sqrt(A3/255.0)) | 255.0*(sqrt(R3/255.0)) | 255.0*(sqrt(G3/255.0)) | 255.0*(sqrt(B3/255.0)) | 255.0*(sqrt(A2/255.0)) | 255.0*(sqrt(R2/255.0)) | 255.0*(sqrt(G2/255.0)) | 255.0*(sqrt(B2/255.0)) |
  packuswb xmm1, xmm3   ; xmm1 = | 255.0*(sqrt(A3/255.0)) | 255.0*(sqrt(R3/255.0)) | 255.0*(sqrt(G3/255.0)) | 255.0*(sqrt(B3/255.0)) | 255.0*(sqrt(A2/255.0)) | 255.0*(sqrt(R2/255.0)) | 255.0*(sqrt(G2/255.0)) | 255.0*(sqrt(B2/255.0)) | 255.0*(sqrt(A1/255.0)) | 255.0*(sqrt(R1/255.0)) | 255.0*(sqrt(G1/255.0)) | 255.0*(sqrt(B1/255.0)) | 255.0*(sqrt(A0/255.0)) | 255.0*(sqrt(R0/255.0)) | 255.0*(sqrt(G0/255.0)) | 255.0*(sqrt(B0/255.0)) |

  por xmm1, xmm11       ; byte transparencia = 255
  movdqu [rsi], xmm1

  lea rdi, [rdi + 16]
  lea rsi, [rsi + 16]

  inc r8d
  jmp .cicloColumnas

.finCicloColumnas:
  dec ecx
  jmp .cicloFilas

.fin:
  pop rbp
  ret
