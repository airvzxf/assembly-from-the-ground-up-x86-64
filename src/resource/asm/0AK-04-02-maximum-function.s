    # PURPOSE:
    #     Solution to Chapter 4, "Use the Concepts":
    #     the maximum program as a function that
    #     receives the address of a list, called
    #     with three different lists.
    #
    # OUTPUT:
    #     Exit status 99 (the maximum of list_3).
    #
    .section .note.GNU-stack,"",@progbits

    .section .data
        list_1:
            .quad 3, 67, 34, 222, 45, 0
        list_2:
            .quad 5, 4, 3, 2, 1, 0
        list_3:
            .quad 10, 99, 18, 50, 0

    .section .text
        .globl _start

_start:
    leaq  list_1(%rip), %rdi # Address of the list.
    call  maximum            # %rax = 222
    leaq  list_2(%rip), %rdi
    call  maximum            # %rax = 5
    leaq  list_3(%rip), %rdi
    call  maximum            # %rax = 99

    movq  %rax, %rdi         # Last result as the
    movq  $60, %rax          # status code.
    syscall

    # PURPOSE: Find the largest number of a list.
    #
    # INPUT:   %rdi - Address of a list of quads
    #                 that ends with a 0.
    # OUTPUT:  %rax - The largest number.
    #
    # VARIABLES:
    #     %rdi - Address of the current item.
    #     %rcx - Current item.
    #
    .type maximum, @function
maximum:
    pushq %rbp
    movq  %rsp, %rbp

    movq  (%rdi), %rax       # Largest so far.

maximum_loop:
    movq  (%rdi), %rcx       # Current item.
    cmpq  $0, %rcx           # End of the list?
    je    maximum_end
    cmpq  %rax, %rcx
    jle   maximum_next
    movq  %rcx, %rax         # New largest value.

maximum_next:
    addq  $8, %rdi           # Next item.
    jmp   maximum_loop

maximum_end:
    movq  %rbp, %rsp
    popq  %rbp
    ret
