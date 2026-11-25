    # PURPOSE:
    #     Solution to Chapter 6, "Going Further": the
    #     `compare_strings` function, which compares
    #     two strings up to 5 characters.
    #
    # INPUT:
    #     %rdi - Address of string A.
    #     %rsi - Address of string B.
    #
    # OUTPUT:
    #     %rax - 1 if A is a prefix of B (comparing
    #     at most 5 characters of A and stopping at
    #     the null byte of A), 0 otherwise.
    #     An empty A matches every string.
    #
    .section .note.GNU-stack,"",@progbits

        .equ MAX_CHARS, 5

    .section .text
        .globl compare_strings
        .type  compare_strings, @function
compare_strings:
    pushq %rbp
    movq  %rsp, %rbp

    movq  $0, %rcx           # Index.
compare_loop:
    cmpq  $MAX_CHARS, %rcx   # 5 characters done?
    je    match
    movb  (%rdi,%rcx,1), %al
    cmpb  $0, %al            # End of A?
    je    match
    movb  (%rsi,%rcx,1), %dl
    cmpb  %al, %dl
    jne   no_match
    incq  %rcx
    jmp   compare_loop

match:
    movq  $1, %rax
    jmp   compare_end
no_match:
    movq  $0, %rax
compare_end:
    movq  %rbp, %rsp
    popq  %rbp
    ret
