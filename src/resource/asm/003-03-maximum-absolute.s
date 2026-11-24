    # PURPOSE:
    #     The maximum program written with absolute
    #     indexed addressing, as older texts do. It
    #     only works in programs linked without PIE.
    #
    # ABSOLUTE_OK: example for the box "Absolute
    #     Addresses and PIE" in Chapter 3. Linking it
    #     with `ld -pie` fails on purpose.
    #
    # VARIABLES:
    #     %rcx - Index of the data item being examined.
    #     %rdi - Largest data item found.
    #     %rax - Current data item.
    #
    .section .note.GNU-stack,"",@progbits

    .section .data
        data_items:
            .quad 3, 67, 34, 222, 45, 22, 11, 125, 0

    .section .text
        .globl _start

_start:
    movq $0, %rcx
    movq data_items(,%rcx,8), %rax  # Absolute
    movq %rax, %rdi                 # address.

_start_loop:
    cmpq $0, %rax
    je _loop_exit
    incq %rcx
    movq data_items(,%rcx,8), %rax
    cmpq %rdi, %rax
    jle _start_loop
    movq %rax, %rdi
    jmp _start_loop

_loop_exit:
    movq $60, %rax           # exit(); %rdi holds
    syscall                  # the maximum.
