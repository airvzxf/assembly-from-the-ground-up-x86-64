    # Link with `0AK-05-00-convert-to-upper.o` and
    # the C library (see `make.bash`).
    #
    # PURPOSE:
    #     Solution to Chapter 8, "Use the Concepts":
    #     `005-01-toupper` using the C library file
    #     functions (fopen, fread, fwrite, fclose)
    #     instead of system calls.
    #
    # USAGE:
    #     ./0AK-08-03-toupper-libc input.txt output.txt
    #
    # NOTES:
    #     The C library functions preserve %rbx, %rbp
    #     and %r12 to %r15, so the FILE pointers are
    #     kept in %rbx and %r12, and the number of
    #     bytes read in %r13. No instruction pushes
    #     anything, so %rsp stays a multiple of 16, as
    #     it was when the program started.
    #     `stderr` is a variable of the C library: its
    #     address is in the GOT (see the solution).
    #
    .section .note.GNU-stack,"",@progbits

    .section .data
        mode_read:
            .ascii "r\0"
        mode_write:
            .ascii "w\0"
        msg_error:
            .ascii "Error: can't open the files\n\0"

    .section .bss
        .equ   BUFFER_SIZE, 500
        .lcomm BUFFER_DATA, BUFFER_SIZE

    .section .text
        .globl _start
        .equ ST_ARGC,   0
        .equ ST_ARGV_1, 16
        .equ ST_ARGV_2, 24

_start:
    movq  %rsp, %rbp
    cmpq  $3, ST_ARGC(%rbp)  # Program name and two
    jne   error              # file names.

    movq  ST_ARGV_1(%rbp), %rdi  # fopen(argv[1], "r")
    leaq  mode_read(%rip), %rsi
    call  fopen@PLT
    movq  %rax, %rbx         # FILE * or NULL.

    movq  ST_ARGV_2(%rbp), %rdi  # fopen(argv[2], "w")
    leaq  mode_write(%rip), %rsi
    call  fopen@PLT
    movq  %rax, %r12

    cmpq  $0, %rbx           # NULL means error.
    je    error
    cmpq  $0, %r12
    je    error

read_loop:
    leaq  BUFFER_DATA(%rip), %rdi  # fread(buffer, 1,
    movq  $1, %rsi                 #       size, in)
    movq  $BUFFER_SIZE, %rdx
    movq  %rbx, %rcx
    call  fread@PLT
    cmpq  $0, %rax           # 0 = end of file or
    je    close_files        # error.
    movq  %rax, %r13         # Bytes read.

    leaq  BUFFER_DATA(%rip), %rdi
    movq  %r13, %rsi
    call  convert_to_upper

    leaq  BUFFER_DATA(%rip), %rdi  # fwrite(buffer, 1,
    movq  $1, %rsi                 #     count, out)
    movq  %r13, %rdx
    movq  %r12, %rcx
    call  fwrite@PLT
    jmp   read_loop

close_files:
    movq  %r12, %rdi
    call  fclose@PLT
    movq  %rbx, %rdi
    call  fclose@PLT
    movq  $0, %rdi
    call  exit@PLT

error:
    leaq  msg_error(%rip), %rdi  # fputs(msg_error,
    movq  stderr@GOTPCREL(%rip), %rsi  #   stderr)
    movq  (%rsi), %rsi
    call  fputs@PLT
    movq  $1, %rdi
    call  exit@PLT
