global binomial_coefficient: function
global calculateRow: function
global main: function

extern fopen, fclose, printf, scanf, fprintf, puts, pow

SECTION .data

prompt_input:      db "Enter x, alpha and eps: ", 0
input_format:      db "%lf %lf %lf", 0
file_mode:         db "w", 0
error_open_file:   db "Error open file.", 0
error_x_range:     db "Error: |x| must be < 1", 0
error_eps:         db "Error: eps must be > 0", 0
term_format:       db "%d: %.15lf", 10, 0
result_format:     db "Result: (1 + %lf)^%lf = %lf", 10, 0
pow_result_format  db "Answer with pow: %lf", 10, 0
ONE:               dq 1.0
ZERO:              dq 0.0
ABS_MASK:          dq 0x7FFFFFFFFFFFFFFF

x: 				   dq 0.0
alpha: 			   dq 0.0
eps: 			   dq 0.0
FileName: 		   dq 0.0
result_value: 	   dq 0.0
pow_result_value:  dq 0.0

section .bss

arg_count: 		   resd 1
arg_value: 		   resq 1

SECTION .text	exec



binomial_coefficient:
    movapd   xmm1, xmm0           ; сохраним alpha
    movsd    xmm2, [ONE]          ; xmm2 = 1.0 (результат)
    movapd   xmm3, xmm2           ; xmm3 = 1.0 (константа для +1)

    test     edi, edi
    jle      .done                ; если k <= 0, сразу вернуть 1.0

    xor      ecx, ecx             ; i = 0
.loop:
    inc      ecx                  ; ++i
    cvtsi2sd xmm4, ecx            ; xmm4 = (double)i

    movapd   xmm0, xmm1           ; xmm0 = alpha
    subsd    xmm0, xmm4           ; xmm0 = alpha - i
    addsd    xmm0, xmm3           ; xmm0 = alpha - i + 1
    divsd    xmm0, xmm4           ; xmm0 = (alpha - i + 1)/i

    mulsd    xmm2, xmm0           ; result *= xmm0

    cmp      ecx, edi
    jl       .loop

.done:
    movapd   xmm0, xmm2           ; вернуть result
    ret
		
		
		

calculateRow:
        push    rbp
        mov     rbp, rsp
        sub     rsp, 64
        movsd   qword [rbp-28H], xmm0    ; сохраняем x
        movsd   qword [rbp-30H], xmm1    ; сохраняем alpha
        movsd   qword [rbp-38H], xmm2    ; сохраняем eps
        mov     qword [rbp-40H], rdi     ; сохраняем file pointer
        movsd   xmm0, qword [rel ONE]     ; sum = 1.0
        movsd   qword [rbp-18H], xmm0     ; sum
        mov     dword [rbp-1CH], 1        ; k = 1

series_loop:
        ; вычисляем биномиальный коэффициент C(alpha, k)
        mov     edx, dword [rbp-1CH]      ; k
        mov     rax, qword [rbp-30H]     ; alpha
        mov     edi, edx                 ; k
        movq    xmm0, rax                ; alpha
        call    binomial_coefficient
        movq    rax, xmm0
        mov     qword [rbp-10H], rax      ; сохраняем биномиальный коэффициент
        
        ; вычисляем x^k
        pxor    xmm0, xmm0
        cvtsi2sd xmm0, dword [rbp-1CH]   ; k
        mov     rax, qword [rbp-28H]     ; x
        movapd  xmm1, xmm0               ; k
        movq    xmm0, rax                ; x
        call    pow                      ; x^k
        
        ; вычисляем term = C(alpha,k) * x^k
        movsd   xmm1, qword [rbp-10H]    ; биномиальный коэффициент
        mulsd   xmm0, xmm1               ; term = C(alpha,k) * x^k
        movsd   qword [rbp-8H], xmm0     ; сохраняем term
        
        ; проверяем условие |term| > eps
        movsd   xmm0, qword [rbp-8H]     ; term
        movq    xmm1, qword [rel ABS_MASK] ; маска для абсолютного значения
        andpd   xmm1, xmm0               ; |term|
        movsd   xmm0, qword [rbp-38H]    ; eps
        comisd  xmm0, xmm1               ; сравниваем eps с |term|
        jnc     series_end               ; если eps >= |term|, заканчиваем
        
        ; печатаем term в файл
        mov     rcx, qword [rbp-8H]      ; term
        mov     edx, dword [rbp-1CH]     ; k
        mov     rax, qword [rbp-40H]     ; file pointer
        movq    xmm0, rcx
        lea     rcx, [rel term_format]   ; формат строки
        mov     rsi, rcx
        mov     rdi, rax
        mov     eax, 1
        call    fprintf
        
        ; добавляем term к сумме
        movsd   xmm0, qword [rbp-18H]    ; sum
        addsd   xmm0, qword [rbp-8H]     ; sum += term
        movsd   qword [rbp-18H], xmm0    ; сохраняем sum
        
        ; увеличиваем k
        add     dword [rbp-1CH], 1        ; k++
        jmp     series_loop

series_end:
        nop
        movsd   xmm0, qword [rbp-18H]    ; возвращаем sum
        movq    rax, xmm0
        movq    xmm0, rax
        leave
        ret
		
		
		
		 

main:
        push    rbp
        mov     rbp, rsp
        sub     rsp, 64
        mov     dword [arg_count], edi
        mov     qword [arg_value], rsi

        xor     eax, eax
        lea     rax, [prompt_input]
        mov     rdi, rax
        mov     eax, 0
        call    printf

        lea     rsi, [x]
        lea     rdx, [alpha]
        lea     rcx, [eps]
        mov     rdi, input_format
        mov     eax, 0
        call    scanf

        ; |x| < 1
        movsd   xmm0, qword [x] 
        movq    xmm1, qword [ABS_MASK]
        andpd   xmm0, xmm1           ; Абсолютное значение x
        movsd   xmm1, qword [ONE]
        comisd  xmm0, xmm1           ; Сравнение |x| с 1.0
        jnc     x_invalid            ; Если |x| >= 1, переход к ошибке
		
		;eps > 0
		
		movsd   xmm0, qword[eps]
		movq    xmm1, qword [ZERO]
		comisd  xmm0, xmm1
		jbe     eps_invalid


        ; Открытие файла 
        mov     rax, qword [arg_value]
        add     rax, 8
        mov     rax, qword [rax]     ; argv[1]
        lea     rdx, [file_mode]
        mov     rsi, rdx
        mov     rdi, rax
        call    fopen
        mov     qword [FileName], rax
        cmp     qword [FileName], 0
        jnz     file_opened          

        ; Ошибка открытия файла
        lea     rax, [error_open_file]
        mov     rdi, rax
        call    puts
        jmp     exit_label



file_opened:
        
        movsd   xmm0, qword [x]
        movsd   xmm1, qword [alpha]
        movsd   xmm2, qword [eps]
        mov     rdi,  qword [FileName]
        call    calculateRow
		
        movq    rax, xmm0
        mov     qword [result_value], rax
        mov     rax, qword [FileName]
        mov     rdi, rax
        call    fclose
		
        movsd   xmm0, qword [x]
        movsd   xmm1, qword [alpha]
        movsd   xmm2, qword [result_value]

        mov     rdi, result_format
        mov     eax, 3
        call    printf
		
		
		
		movsd   xmm0, qword [x]
        movsd   xmm1, qword [ONE]
        addsd   xmm0, xmm1          ; xmm0 = 1 + x
        movsd   xmm1, qword [alpha] ; xmm1 = alpha
        call    pow                 ; xmm0 = pow(1 + x, alpha)

        lea     rax, [pow_result_format]
        mov     rdi, rax
        mov     eax, 1
        call    printf
		
		
		
		mov     eax, 0
		leave
		ret

exit_label:
        mov     eax, 1
        leave
        ret
		
		
x_invalid:

        lea     rax, [error_x_range]
        mov     rdi, rax
        call    puts
        jmp     exit_label


eps_invalid:
		lea     rax, [error_eps]
        mov     rdi, rax
        call    puts
        jmp     exit_label