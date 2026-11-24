    # PURPOSE:
    #     Solution to Chapter 3, "Going Further":
    #     the first program without the `syscall`
    #     instruction. It crashes on purpose.
    #
    .section .note.GNU-stack,"",@progbits

    .section .data

    .section .text
        .globl _start

_start:
    movq $60, %rax     # exit() system call number.
    movq $0, %rdi      # Status code.
                       # No `syscall`: the kernel is
                       # never called, so the CPU
                       # keeps executing whatever
                       # bytes follow in memory.
