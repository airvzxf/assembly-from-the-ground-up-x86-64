    # PURPOSE:
    #     Solution to Chapter 5, "Use the Concepts":
    #     create the file `heynow.txt` and write
    #     "Hey diddle diddle!" into it.
    #
    .section .note.GNU-stack,"",@progbits

        .equ SYS_WRITE,            1
        .equ SYS_CLOSE,            3
        .equ SYS_EXIT,             60
        .equ SYS_OPENAT,           257
        .equ AT_FDCWD,             -100
        .equ O_CREAT_WRONLY_TRUNC, 01101

    .section .data
        file_name:
            .ascii "heynow.txt\0"
        text:
            .ascii "Hey diddle diddle!\n"
        text_end:
        .equ TEXT_LENGTH, text_end - text

    .section .text
        .globl _start

_start:
    movq  $SYS_OPENAT, %rax
    movq  $AT_FDCWD, %rdi
    leaq  file_name(%rip), %rsi
    movq  $O_CREAT_WRONLY_TRUNC, %rdx
    movq  $0666, %r10        # Permissions.
    syscall
    movq  %rax, %rbx         # File descriptor.

    movq  $SYS_WRITE, %rax
    movq  %rbx, %rdi
    leaq  text(%rip), %rsi
    movq  $TEXT_LENGTH, %rdx
    syscall

    movq  $SYS_CLOSE, %rax
    movq  %rbx, %rdi
    syscall

    movq  $SYS_EXIT, %rax
    movq  $0, %rdi
    syscall
