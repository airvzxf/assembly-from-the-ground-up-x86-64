    # Link with `0AK-05-00-convert-to-upper.o`.
    #
    # PURPOSE:
    #     Solution to Chapter 5, "Use the Concepts":
    #     `005-01-toupper` storing the file
    #     descriptors in the .bss section instead of
    #     the stack. The buffer is also smaller
    #     (16 bytes), which only means more read and
    #     write calls; the result is the same.
    #
    # USAGE:
    #     ./0AK-05-02-toupper-bss input.txt output.txt
    #
    .section .note.GNU-stack,"",@progbits

        .equ SYS_READ,             0
        .equ SYS_WRITE,            1
        .equ SYS_CLOSE,            3
        .equ SYS_EXIT,             60
        .equ SYS_OPENAT,           257
        .equ AT_FDCWD,             -100
        .equ O_RDONLY,             0
        .equ O_CREAT_WRONLY_TRUNC, 01101
        .equ END_OF_FILE,          0
        .equ ST_ARGV_1,            16
        .equ ST_ARGV_2,            24

    .section .bss
        .equ   BUFFER_SIZE, 16
        .lcomm BUFFER_DATA, BUFFER_SIZE
        .lcomm FD_IN,  8     # File descriptors.
        .lcomm FD_OUT, 8

    .section .text
        .globl _start

_start:
    movq  %rsp, %rbp

    movq  $SYS_OPENAT, %rax  # Open the input file.
    movq  $AT_FDCWD, %rdi
    movq  ST_ARGV_1(%rbp), %rsi
    movq  $O_RDONLY, %rdx
    movq  $0666, %r10
    syscall
    movq  %rax, FD_IN(%rip)

    movq  $SYS_OPENAT, %rax  # Open the output file.
    movq  $AT_FDCWD, %rdi
    movq  ST_ARGV_2(%rbp), %rsi
    movq  $O_CREAT_WRONLY_TRUNC, %rdx
    movq  $0666, %r10
    syscall
    movq  %rax, FD_OUT(%rip)

read_loop:
    movq  $SYS_READ, %rax
    movq  FD_IN(%rip), %rdi
    leaq  BUFFER_DATA(%rip), %rsi
    movq  $BUFFER_SIZE, %rdx
    syscall
    cmpq  $END_OF_FILE, %rax
    jle   close_files

    movq  %rax, %rbx         # Bytes read.
    leaq  BUFFER_DATA(%rip), %rdi
    movq  %rbx, %rsi
    call  convert_to_upper

    movq  $SYS_WRITE, %rax
    movq  FD_OUT(%rip), %rdi
    leaq  BUFFER_DATA(%rip), %rsi
    movq  %rbx, %rdx
    syscall
    jmp   read_loop

close_files:
    movq  $SYS_CLOSE, %rax
    movq  FD_OUT(%rip), %rdi
    syscall
    movq  $SYS_CLOSE, %rax
    movq  FD_IN(%rip), %rdi
    syscall

    movq  $SYS_EXIT, %rax
    movq  $0, %rdi
    syscall
