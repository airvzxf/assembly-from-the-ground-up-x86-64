    # Link with `0AK-10-01-integer2string-base.o`,
    # `0AK-08-01-factorial-lib.o` and
    # `006-01-write-newline.o`.
    #
    # PURPOSE:
    #     Solution to Chapter 10, "Use the Concepts":
    #     print a result instead of returning it as
    #     the exit status (the factorial of 5, which
    #     no longer has the 255 limit: 10! and 20!
    #     work too), and print 255 in several bases.
    #
    # OUTPUT:
    #     120
    #     3628800
    #     2432902008176640000
    #     377
    #     ff
    #     11111111
    #     73
    #
    .section .note.GNU-stack,"",@progbits

    .include "006-01-linux.s"

    .section .bss
        .lcomm buffer, 65

    .section .text
        .globl _start
_start:
    movq  $5, %rdi           # 5!
    call  factorial
    movq  %rax, %rdi         # In base 10.
    movq  $10, %rsi
    call  print_number

    movq  $10, %rdi          # 10! = 3628800, too
    call  factorial          # big for an exit
    movq  %rax, %rdi         # status code.
    movq  $10, %rsi
    call  print_number

    movq  $20, %rdi          # 20!, the biggest that
    call  factorial          # fits in 64 bits.
    movq  %rax, %rdi
    movq  $10, %rsi
    call  print_number

    movq  $255, %rdi         # 255 in octal,
    movq  $8, %rsi
    call  print_number
    movq  $255, %rdi         # hexadecimal,
    movq  $16, %rsi
    call  print_number
    movq  $255, %rdi         # binary
    movq  $2, %rsi
    call  print_number
    movq  $255, %rdi         # and base 36.
    movq  $36, %rsi
    call  print_number

    movq  $SYS_EXIT, %rax
    movq  $0, %rdi
    syscall

    # PURPOSE:
    #     Print a number in a base and a newline.
    #
    # INPUT:
    #     %rdi - The number.
    #     %rsi - The base.
    #
        .type print_number, @function
print_number:
    pushq %rbp
    movq  %rsp, %rbp

    movq  %rsi, %rdx         # integer2string_base(
    leaq  buffer(%rip), %rsi #   number, buffer,
    call  integer2string_base  # base)

    movq  %rax, %rdx         # Length.
    movq  $SYS_WRITE, %rax
    movq  $STDOUT, %rdi
    leaq  buffer(%rip), %rsi
    syscall

    movq  $STDOUT, %rdi
    call  write_newline

    movq  %rbp, %rsp
    popq  %rbp
    ret
