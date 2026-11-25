    # PURPOSE:
    #     This program writes the message
    #     "hello world" and exits.
    #
    .section .note.GNU-stack,"",@progbits

    .include "006-01-linux.s"      # Linux Definitions.

    .section .data
        helloworld:
            .ascii "hello world\n"
        helloworld_end:
            .equ length, helloworld_end - helloworld

    .section .text
        .globl _start

_start:
    movq  $SYS_WRITE, %rax
    movq  $STDOUT, %rdi
    leaq  helloworld(%rip), %rsi
    movq  $length, %rdx
    syscall

    movq  $SYS_EXIT, %rax
    movq  $0, %rdi
    syscall
