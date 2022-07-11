global Gamma_lookup_table_ymm_asm

section .rodata
ALIGN 16

mascara_transparencia: times 4 db 0x00, 0x00, 0x00, 0xFF
mascara_gather: times 32 db 0xFF
lookup_table:
dd 0,15,22,27,31,35,39,42,45,47,50,52,55,57,59,61,
dd 63,65,67,69,71,73,74,76,78,79,81,82,84,85,87,88,
dd 90,91,93,94,95,97,98,99,100,102,103,104,105,107,108,109,
dd 110,111,112,114,115,116,117,118,119,120,121,122,123,124,125,126,
dd 127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,141,
dd 142,143,144,145,146,147,148,148,149,150,151,152,153,153,154,155,
dd 156,157,158,158,159,160,161,162,162,163,164,165,165,166,167,168,
dd 168,169,170,171,171,172,173,174,174,175,176,177,177,178,179,179,
dd 180,181,182,182,183,184,184,185,186,186,187,188,188,189,190,190,
dd 191,192,192,193,194,194,195,196,196,197,198,198,199,200,200,201,
dd 201,202,203,203,204,205,205,206,206,207,208,208,209,210,210,211,
dd 211,212,213,213,214,214,215,216,216,217,217,218,218,219,220,220,
dd 221,221,222,222,223,224,224,225,225,226,226,227,228,228,229,229,
dd 230,230,231,231,232,233,233,234,234,235,235,236,236,237,237,238,
dd 238,239,240,240,241,241,242,242,243,243,244,244,245,245,246,246,
dd 247,247,248,248,249,249,250,250,251,251,252,252,253,253,254,255


section .text
Gamma_lookup_table_ymm_asm:
  ; rdi = uint8_t *src
  ; rsi = uint8_t *dst
  ; edx = int width
  ; ecx = int height
  ; r8d = int src_row_size
  ; r9d int dst_row_size
  push rbp
  mov rbp, rsp

  movdqu xmm11, [mascara_transparencia]
  vmovdqu ymm12, [mascara_gather]
  mov r9, lookup_table    ; r9<- puntero a lookup_table

  shr edx,2             ; width / 4
.cicloFilas:
  cmp ecx, 0
  je .fin
  mov r8d, 0
.cicloColumnas:
  cmp r8d, edx
  je .finCicloColumnas  

  vpmovzxbd ymm1, [rdi]
  vpmovzxbd ymm2, [rdi+8]

  vmovdqa ymm13, ymm12
  vpgatherdd ymm3, [r9 + ymm1 * 4], ymm13 ;se limpia xmm13 por la instruccion
  vmovdqa ymm13, ymm12
  vpgatherdd ymm4, [r9 + ymm2 * 4], ymm13

  vextracti128 xmm1, ymm3, 0x0
  vextracti128 xmm2, ymm3, 0x1
  vextracti128 xmm3, ymm4, 0x0
  vextracti128 xmm4, ymm4, 0x1
  
  packusdw xmm1, xmm2
  packusdw xmm3, xmm4
  packuswb xmm1, xmm3

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
