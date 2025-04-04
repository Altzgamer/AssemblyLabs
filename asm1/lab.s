bits 64

section .data
    res dq 0
    a dd 0x40000000
    b dd 1
    c dq 0x4000000000000000
    d dw 64
    e db 64
;2^30+ 2^23 - 2^6 + 2^36
;69801607104

section .text
    global _start

_start:
    mov rax, qword [c]
    movsx rbx, dword [b]
    imul rax, rbx
    jo error_exit
    mov rsi, rax

    movsx rcx, word [d]
    movsx rdx, byte [e]
    add rcx, rdx
    or rcx, rcx
    jz error_exit
    movsx rax, dword [a]
    cqo
    idiv rcx
    add rsi, rax
	jo error_exit
	
    movsx rax, word [d]
    imul rax, rax
    jo error_exit

    movsx rcx, dword [b]
    movsx rdx, byte [e]
    imul rcx, rdx
    jo error_exit
    or rcx, rcx
    jz error_exit
    cqo
    idiv rcx
    sub rsi, rax

    movsx rax, dword [a]
    movsx rcx, byte [e]
    imul rax, rcx
    jo error_exit
    add rsi, rax

    mov [res], rsi

    mov eax, 60
    xor edi, edi
    syscall

error_exit:
    mov eax, 60
    mov edi, 1
    syscall
