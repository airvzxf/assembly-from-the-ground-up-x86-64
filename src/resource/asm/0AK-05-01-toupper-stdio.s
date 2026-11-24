    # Link with `0AK-05-00-convert-to-upper.o`.
    #
    # PURPOSE:
    #     Solution to Chapter 5, "Use the Concepts":
    #     convert STDIN to upper case and write it to
    #     STDOUT. No files are opened or closed: the
    #     shell already opened file descriptors 0
    #     and 1 for us.
    #
    # USAGE:
    #     echo "hello" | ./0AK-05-01-toupper-stdio
    #
    .section .note.GNU-stack,"",@progbits

        .equ SYS_READ,     0
        .equ SYS_WRITE,    1
        .equ SYS_EXIT,     60
        .equ STDIN,        0
        .equ STDOUT,       1
        .equ END_OF_FILE,  0

    .section .bss
        .equ   BUFFER_SIZE, 500
        .lcomm BUFFER_DATA, BUFFER_SIZE

    .section .text
        .globl _start

_start:
read_loop:
    movq  $SYS_READ, %rax
    movq  $STDIN, %rdi
    leaq  BUFFER_DATA(%rip), %rsi
    movq  $BUFFER_SIZE, %rdx
    syscall
    cmpq  $END_OF_FILE, %rax # End of file (0) or
    jle   exit               # error (negative)?

    movq  %rax, %rbx         # Bytes read.
    leaq  BUFFER_DATA(%rip), %rdi
    movq  %rbx, %rsi
    call  convert_to_upper

    movq  $SYS_WRITE, %rax
    movq  $STDOUT, %rdi
    leaq  BUFFER_DATA(%rip), %rsi
    movq  %rbx, %rdx
    syscall
    jmp   read_loop

exit:
    movq  $SYS_EXIT, %rax
    movq  $0, %rdi
    syscall
