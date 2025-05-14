section .data
    open_error_msg      db "Ошибка открытия файла", 0xA, 0
    open_error_len      equ $-open_error_msg
    
    read_error_msg      db "Ошибка чтения из файла", 0xA, 0
    read_error_len      equ $-read_error_msg
    
    close_error_msg     db "Ошибка закрытия файла", 0xA, 0
    close_error_len     equ $-close_error_msg
    
    arg_error_msg       db "Не указано имя файла", 0xA, 0
    arg_error_len       equ $-arg_error_msg

section .bss
    in_fd       resq 1
    buffer      resb 4096

section .text
    global _start

%macro handle_error 2
    mov rax, 1            ; sys_write
    mov rdi, 2            ; STDERR
    mov rsi, %1
    mov rdx, %2
    syscall
    mov rax, 60           ; sys_exit
    mov rdi, 1            ; код ошибки
    syscall
%endmacro

_start:
    pop rcx               ; получаем argc
    cmp rcx, 2            ; только имя файла иначе ошибка
    jl .arg_error
    
    pop rdi               ; пропускаем argv0
    pop rdi               ;  argv1 имя файла

    ; Открываем файл для чтения
    mov rax, 2            ; sys_open
    mov rsi, 0            ; O_RDONLY
    syscall
    
    cmp rax, 0
    jl .open_error
    mov [in_fd], rax

.read_loop:
    ; Чтение из файла
    mov rax, 0            ; sys_read
    mov rdi, [in_fd]
    mov rsi, buffer
    mov rdx, 4096
    syscall
    
    cmp rax, 0
    jl .read_error
    je .exit              ; если достигнут конец файла
    
    ; Обработка прочитанных данных
    mov rcx, rax          ; сохраняем длину прочитанных данных
    mov rsi, buffer       ; источник
    mov rdi, buffer       ; приемник

.process_loop:
    cmp rcx, 0
    je .output_result

    mov al, [rsi]
    inc rsi
    dec rcx

    ; Обработка символов
    cmp al, 0x20
    je .handle_whitespace
    cmp al, 0x9
    je .handle_whitespace

    cmp al, 'A'
    jl .store_char
    cmp al, 'Z'
    jg .check_lower
    add al, 0x20
    jmp .store_char

.check_lower:
    cmp al, 'a'
    jl .store_char
    cmp al, 'z'
    jg .store_char
    sub al, 0x20

.store_char:
    mov [rdi], al
    inc rdi
    jmp .process_loop

.handle_whitespace:

    cmp rdi, buffer
    je .skip_whitespace
    cmp byte [rdi-1], 0xA
    je .skip_whitespace
    cmp byte [rdi-1], 0x20
    je .skip_whitespace
    mov byte [rdi], 0x20
    inc rdi
    jmp .process_loop


.skip_whitespace:
    jmp .process_loop

.output_result:
    ; Удаляем последний пробел
    cmp rdi, buffer
    je .prepare_output
    cmp byte [rdi-1], 0x20
    jne .prepare_output
    dec rdi

.prepare_output:
    mov rdx, rdi
    sub rdx, buffer       ; вычисляем длину обработанной строки
    
	
	
    ; Вывод результата
    mov rax, 1            ; sys_write
    mov rdi, 1            ; STDOUT
    mov rsi, buffer
    syscall
    
    jmp .read_loop        ; продолжаем чтение файла

.arg_error:
    handle_error arg_error_msg, arg_error_len

.open_error:
    handle_error open_error_msg, open_error_len

.read_error:
    handle_error read_error_msg, read_error_len

.exit:
    ; Закрытие файла
    mov rax, 3            ; sys_close
    mov rdi, [in_fd]
    syscall
    cmp rax, 0
    jl .close_error
    
    ; Завершение программы
    mov rax, 60
    xor rdi, rdi
    syscall

.close_error:
    handle_error close_error_msg, close_error_len