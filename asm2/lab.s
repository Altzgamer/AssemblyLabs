%ifdef SORT_ORDER
    %define sort_order SORT_ORDER
%else
    %define sort_order 0
%endif 

section .data
    rows        dq 10
    cols        dq 10
    elem_size   dq 8

    matrix      dq  5, -3, 12,  8,  6,  7,  2, -1, 14,  9,
                dq 10,  0, -5,  3,  8,  1, 11, -2,  7,  4,
                dq -7,  6,  2,  9, -3,  5,  8,  0,  1, 12,
                dq  4, -8,  7,  2, 11, -6,  3,  5, 10,  0,
                dq  9, -2,  1,  6,  4,  8, 12, -7,  5,  3,
                dq  2,  5, -1,  7, -4, 10,  6,  3,  8,  9,
                dq  0, 12,  4, -6,  5,  9, -3,  7, 11,  2,
                dq  6, -9,  8,  1,  3,  2,  4, 10,  7,  5,
                dq -5,  7, 11,  0,  6, -2,  9,  8,  3,  1,
                dq  3,  1,  9,  5, -8,  7, 10,  2, -6,  4

    col_ptrs    dq 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    min_vals    dq 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

section .text
    global _start

_start:
    ; Инициализация указателей на столбцы
    mov rdi, matrix
    mov rsi, col_ptrs
    mov rcx, [cols]
init_col_ptrs:
    mov [rsi], rdi
    mov rax, [elem_size]
    add rsi, rax
    add rdi, rax
    loop init_col_ptrs

    ; Поиск минимальных значений в столбцах
    mov rcx, [cols]
    mov rsi, col_ptrs
find_min:
    mov rdi, [rsi]
    mov rax, [rdi]
    mov rdx, [rows]
next_row:
    cmp [rdi], rax
    cmovl rax, [rdi]
    mov rbx, [cols]
    imul rbx, [elem_size]
    add rdi, rbx
    dec rdx
    jnz next_row
    mov [min_vals + (rsi - col_ptrs)], rax
    mov rax, [elem_size]
    add rsi, rax
    loop find_min

    ; Шейкерная сортировка
    mov rcx, 0
    mov rax, [cols]
    dec rax
    mov rdx, rax
shaker_sort:
    cmp rcx, rdx
    jge sort_done
    mov rsi, rcx
forward_pass:
    cmp rsi, rdx
    jge forward_done
    mov r8, min_vals
    mov rax, [r8 + rsi*8]
    mov rbx, [r8 + rsi*8 + 8]
    cmp qword [sort_order], 0
    je ascending_f
    cmp rax, rbx
    jge no_swap_f
    jmp swap_f
ascending_f:
    cmp rax, rbx
    jle no_swap_f
swap_f:
    mov [r8 + rsi*8], rbx
    mov [r8 + rsi*8 + 8], rax
    mov r9, [col_ptrs + rsi*8]
    mov r10, [col_ptrs + rsi*8 + 8]
    mov [col_ptrs + rsi*8], r10
    mov [col_ptrs + rsi*8 + 8], r9
no_swap_f:
    inc rsi
    jmp forward_pass
forward_done:
    dec rdx
    mov rsi, rdx
backward_pass:
    cmp rsi, rcx
    jle backward_done
    mov r8, min_vals
    mov rax, [r8 + rsi*8 - 8]
    mov rbx, [r8 + rsi*8]
    cmp qword [sort_order], 0
    je ascending_b
    cmp rax, rbx
    jge no_swap_b
    jmp swap_b
ascending_b:
    cmp rax, rbx
    jle no_swap_b
swap_b:
    mov [r8 + rsi*8 - 8], rbx
    mov [r8 + rsi*8], rax
    mov r9, [col_ptrs + rsi*8 - 8]
    mov r10, [col_ptrs + rsi*8]
    mov [col_ptrs + rsi*8 - 8], r10
    mov [col_ptrs + rsi*8], r9
no_swap_b:
    dec rsi
    jmp backward_pass
backward_done:
    inc rcx
    jmp shaker_sort

sort_done:
    ; Перестановка столбцов
    mov rax, [rows]
    imul rax, [cols]
    imul rax, [elem_size]
    mov r15, rax
    sub rsp, rax
    mov rbx, rsp

    mov r8, 0
row_loop:
    cmp r8, [rows]
    jge row_done
    mov r9, 0
col_loop:
    cmp r9, [cols]
    jge col_done
    mov rsi, [col_ptrs + r9*8]
    mov rax, [cols]
    imul rax, [elem_size]
    imul rax, r8
    add rsi, rax
    mov rax, [rsi]
    mov rdx, r8
    imul rdx, [cols]
    add rdx, r9
    imul rdx, [elem_size]
    mov [rbx + rdx], rax
    inc r9
    jmp col_loop
col_done:
    inc r8
    jmp row_loop
row_done:

    mov rsi, rbx
    mov rdi, matrix
    mov rcx, [rows]
    imul rcx, [cols]
    rep movsq
    add rsp, r15

    mov eax, 60
    xor edi, edi
    syscall