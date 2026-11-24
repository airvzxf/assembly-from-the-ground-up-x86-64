    # PURPOSE:
    #     Solution to Chapter 4, "Use the Concepts":
    #     a `square` function and a program to test
    #     it.
    #
    # OUTPUT:
    #     Exit status 144 (the square of 12).
    #
    .section .note.GNU-stack,"",@progbits

    .section .data

    .section .text
        .globl _start

_start:
    movq  $12, %rdi          # Argument.
    call  square
    movq  %rax, %rdi         # Result as the status.
    movq  $60, %rax          # exit()
    syscall

    # PURPOSE: Return the square of a number.
    #
    # INPUT:   %rdi - The number.
    # OUTPUT:  %rax - The number times itself.
    #
    .type square, @function
square:
    pushq %rbp               # Standard function
    movq  %rsp, %rbp         # prologue.

    movq  %rdi, %rax         # %rax = argument.
    imulq %rax, %rax         # %rax = %rax * %rax.

    movq  %rbp, %rsp         # Standard function
    popq  %rbp               # epilogue.
    ret
