    # PURPOSE:
    #     Solution to Chapter 4, "Going Further":
    #     the factorial function written with a loop
    #     instead of recursion.
    #
    # OUTPUT:
    #     Exit status 120 (the factorial of 5).
    #
    .section .note.GNU-stack,"",@progbits

    .section .data

    .section .text
        .globl _start

_start:
    movq  $5, %rdi
    call  factorial
    movq  %rax, %rdi
    movq  $60, %rax
    syscall

    # INPUT:   %rdi - The number.
    # OUTPUT:  %rax - Its factorial.
    #
    .type factorial, @function
factorial:
    pushq %rbp
    movq  %rsp, %rbp

    movq  $1, %rax           # Result.

factorial_loop:
    cmpq  $1, %rdi           # Done when n <= 1.
    jle   factorial_end
    imulq %rdi, %rax         # result *= n
    decq  %rdi               # n--
    jmp   factorial_loop

factorial_end:
    movq  %rbp, %rsp
    popq  %rbp
    ret
