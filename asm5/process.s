default rel

section .text
    global grayscale_asm

;   RDI = img        (указатель на пиксели)
;   RSI = width
;   RDX = height
;   RCX = channels

grayscale_asm:
    ; pixels = width * height
    imul    esi, edx            ; ESI = width * height
    test    esi, esi
    jle     .done               ; если нет пикселей — выход

    ; Загружаем коэффициенты в XMM (подразумевается, что они в .rodata)
    movsd   xmm4, [rel .coeff_r]  ; 0.3
    movsd   xmm3, [rel .coeff_g]  ; 0.59
    movsd   xmm2, [rel .coeff_b]  ; 0.11

    ; Подготовим постоянную 255 для клэмпинга
    mov     r11d, 255

    xor     edx, edx            ; EDX = i = 0

.loop_pixels:
    ; --- загрузка каналов ---
    movzx   eax, byte [rdi]        ; R
    pxor    xmm0, xmm0
    cvtsi2sd xmm0, eax

    movzx   eax, byte [rdi + 1]    ; G
    pxor    xmm1, xmm1
    cvtsi2sd xmm1, eax

    movzx   eax, byte [rdi + 2]    ; B

    ; --- вычисление серого: grey = R*0.3 + G*0.59 + B*0.11 ---
    mulsd   xmm0, xmm4              ; xmm0 = R * 0.3
    mulsd   xmm1, xmm3              ; xmm1 = G * 0.59
    addsd   xmm0, xmm1              ; xmm0 = R*0.3 + G*0.59

    pxor    xmm1, xmm1
    cvtsi2sd xmm1, eax              ; xmm1 = (double)B
    mulsd   xmm1, xmm2              ; xmm1 = B * 0.11
    addsd   xmm0, xmm1              ; xmm0 = grey

    cvttsd2si eax, xmm0             ; truncate → EAX

    ; --- clamp: если больше 255, то 255 ---
    cmp     eax, r11d
    cmovg   eax, r11d

    ; --- записываем в R,G,B ---
    mov     byte [rdi],     al
    mov     byte [rdi + 1], al
    mov     byte [rdi + 2], al

    ; Переход к следующему пикселю
    add     rdi, rcx                ; учитываем число channels
    inc     edx
    cmp     edx, esi
    jl      .loop_pixels

.done:
    ret

section .rodata
.coeff_r:    dq 0.3    
.coeff_g:    dq 0.59   
.coeff_b:    dq 0.11    