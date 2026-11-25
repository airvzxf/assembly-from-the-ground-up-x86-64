    # PURPOSE:
    #     Solution to Chapter 10, "Use the Concepts":
    #     the `is_negative` function.
    #
    # OUTPUT:
    #     Exit status code 100:
    #     is_negative(-5) * 100   -> 1 * 100
    #     + is_negative(7) * 10   -> 0 * 10
    #     + is_negative(0)        -> 0
    #
    .section .note.GNU-stack,"",@progbits

    .include "006-01-linux.s"

    .section .text
        .globl _start
_start:
    movq  $-5, %rdi
    call  is_negative
    imulq $100, %rax, %rbx
    movq  $7, %rdi
    call  is_negative
    imulq $10, %rax, %rax
    addq  %rax, %rbx
    movq  $0, %rdi
    call  is_negative
    addq  %rax, %rbx

    movq  $SYS_EXIT, %rax
    movq  %rbx, %rdi
    syscall

    # PURPOSE:
    #     Return 1 if the number is negative, 0 if
    #     it is zero or positive.
    #
    # HOW IT WORKS:
    #     In two's complement, the highest bit (bit
    #     63) is the sign bit. Shifting the number 63
    #     places to the right leaves only that bit.
    #
    # INPUT:
    #     %rdi - The number.
    #
    # OUTPUT:
    #     %rax - 1 or 0.
    #
        .type is_negative, @function
is_negative:
    movq  %rdi, %rax
    shrq  $63, %rax          # Logical shift: fills
    ret                      # with zeros.
