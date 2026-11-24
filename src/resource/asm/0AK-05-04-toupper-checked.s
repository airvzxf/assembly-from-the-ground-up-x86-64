    # Link with `0AK-05-00-convert-to-upper.o`.
    #
    # PURPOSE:
    #     Solution to Chapter 5, "Going Further":
    #     with two arguments, convert the input file
    #     into the output file; with no arguments,
    #     convert STDIN into STDOUT. Every system
    #     call is checked, and errors are reported.
    #
    # USAGE:
    #     ./0AK-05-04-toupper-checked in.txt out.txt
    #     echo "hi" | ./0AK-05-04-toupper-checked
    #
    # NOTES:
    #     The exercise asks for the messages on
    #     STDOUT, but they go to STDERR: that way
    #     they never get mixed with the converted
    #     text when STDOUT is redirected to a file.
    #     Linux returns errors as a negative number
    #     (-errno) in %rax.
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
        .equ STDIN,                0
        .equ STDOUT,               1
        .equ STDERR,               2
        .equ ST_ARGC,              0
        .equ ST_ARGV_1,            16
        .equ ST_ARGV_2,            24

    # Each message is followed by a label at its
    # end, so its length is end - start.
    .section .data
        msg_usage:
            .ascii "Usage: toupper [input output]\n"
        msg_usage_end:
        msg_open_in:
            .ascii "Error: can't open input file\n"
        msg_open_in_end:
        msg_open_out:
            .ascii "Error: can't open output file\n"
        msg_open_out_end:
        msg_read:
            .ascii "Error: read failed\n"
        msg_read_end:
        msg_write:
            .ascii "Error: write failed\n"
        msg_write_end:

    .section .bss
        .equ   BUFFER_SIZE, 500
        .lcomm BUFFER_DATA, BUFFER_SIZE
        .lcomm FD_IN,  8
        .lcomm FD_OUT, 8

    .section .text
        .globl _start

_start:
    movq  %rsp, %rbp
    movq  $STDIN, FD_IN(%rip)    # Defaults.
    movq  $STDOUT, FD_OUT(%rip)

    movq  ST_ARGC(%rbp), %rax
    cmpq  $1, %rax           # No arguments.
    je    read_loop
    cmpq  $3, %rax           # Two arguments.
    je    open_files
    leaq  msg_usage(%rip), %rsi
    movq  $msg_usage_end - msg_usage, %rdx
    jmp   fail

open_files:
    movq  $SYS_OPENAT, %rax
    movq  $AT_FDCWD, %rdi
    movq  ST_ARGV_1(%rbp), %rsi
    movq  $O_RDONLY, %rdx
    movq  $0666, %r10
    syscall
    cmpq  $0, %rax           # Negative = error.
    jl    fail_open_in
    movq  %rax, FD_IN(%rip)

    movq  $SYS_OPENAT, %rax
    movq  $AT_FDCWD, %rdi
    movq  ST_ARGV_2(%rbp), %rsi
    movq  $O_CREAT_WRONLY_TRUNC, %rdx
    movq  $0666, %r10
    syscall
    cmpq  $0, %rax
    jl    fail_open_out
    movq  %rax, FD_OUT(%rip)

read_loop:
    movq  $SYS_READ, %rax
    movq  FD_IN(%rip), %rdi
    leaq  BUFFER_DATA(%rip), %rsi
    movq  $BUFFER_SIZE, %rdx
    syscall
    cmpq  $0, %rax
    jl    fail_read
    je    close_files        # End of file.

    movq  %rax, %rbx         # Bytes read.
    leaq  BUFFER_DATA(%rip), %rdi
    movq  %rbx, %rsi
    call  convert_to_upper

    movq  $SYS_WRITE, %rax
    movq  FD_OUT(%rip), %rdi
    leaq  BUFFER_DATA(%rip), %rsi
    movq  %rbx, %rdx
    syscall
    cmpq  $0, %rax
    jl    fail_write
    jmp   read_loop

close_files:
    movq  $SYS_CLOSE, %rax   # Closing STDIN or
    movq  FD_OUT(%rip), %rdi # STDOUT is harmless
    syscall                  # at exit.
    movq  $SYS_CLOSE, %rax
    movq  FD_IN(%rip), %rdi
    syscall
    movq  $SYS_EXIT, %rax
    movq  $0, %rdi
    syscall

fail_open_in:
    leaq  msg_open_in(%rip), %rsi
    movq  $msg_open_in_end - msg_open_in, %rdx
    jmp   fail
fail_open_out:
    leaq  msg_open_out(%rip), %rsi
    movq  $msg_open_out_end - msg_open_out, %rdx
    jmp   fail
fail_read:
    leaq  msg_read(%rip), %rsi
    movq  $msg_read_end - msg_read, %rdx
    jmp   fail
fail_write:
    leaq  msg_write(%rip), %rsi
    movq  $msg_write_end - msg_write, %rdx

    # Write the message in %rsi (%rdx bytes long)
    # to STDERR and exit with status 1.
fail:
    movq  $SYS_WRITE, %rax
    movq  $STDERR, %rdi
    syscall
    movq  $SYS_EXIT, %rax
    movq  $1, %rdi
    syscall
