    # Link dynamically with the factorial library
    # and the C library:
    #     ld -o 0AK-08-02-factorial-printf \
    #       0AK-08-02-factorial-printf.o \
    #       -L . -l factorial -l c \
    #       -dynamic-linker /lib64/ld-linux-x86-64.so.2
    # Run with:
    #     LD_LIBRARY_PATH=. \
    #       ./0AK-08-02-factorial-printf
    #
    # PURPOSE:
    #     Solution to Chapter 8, "Use the Concepts":
    #     call `factorial` from the shared library
    #     `libfactorial.so`, print the result with
    #     `printf` and exit with status 0.
    #
    # OUTPUT:
    #     The factorial of 5 is 120.
    #
    .section .note.GNU-stack,"",@progbits

    .section .data
        format:
            .ascii "The factorial of %ld is %ld.\n\0"

    .section .text
        .globl _start
        .equ NUMBER, 5

_start:
    movq  $NUMBER, %rdi
    call  factorial@PLT      # From libfactorial.so.

    leaq  format(%rip), %rdi # printf(format, n, n!)
    movq  $NUMBER, %rsi
    movq  %rax, %rdx
    movq  $0, %rax           # No vector registers.
    call  printf@PLT

    movq  $0, %rdi           # exit(0) flushes the
    call  exit@PLT           # printf buffer.
