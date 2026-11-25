    # Link with `0AK-10-01-integer2string-base.o`
    # and `006-01-write-newline.o`.
    #
    # PURPOSE:
    #     Solution to Chapter 10, "Going Further":
    #     the `number2integer` function, the reverse
    #     of `integer2string`. The program reads a
    #     number from STDIN, converts it to an
    #     integer, and prints it back with
    #     `integer2string_base` to test it.
    #
    # USAGE:
    #     echo -0042 | ./0AK-10-04-number2integer
    #     (prints -42)
    #
    .section .note.GNU-stack,"",@progbits

    .include "006-01-linux.s"

        .equ INPUT_SIZE, 32

    .section .data
        minus:
            .ascii "-"

    .section .bss
        .lcomm input, INPUT_SIZE + 1
        .lcomm output, 65

    .section .text
        .globl _start
_start:
    movq  $SYS_READ, %rax
    movq  $STDIN, %rdi
    leaq  input(%rip), %rsi
    movq  $INPUT_SIZE, %rdx
    syscall
    cmpq  $0, %rax
    jle   exit
    leaq  input(%rip), %rdi
    movb  $0, (%rdi,%rax)    # Null-terminate it.
    call  number2integer
    movq  %rax, %rbx         # The integer.

    cmpq  $0, %rbx           # Negative: print the
    jge   print              # sign and the
    movq  $SYS_WRITE, %rax   # absolute value.
    movq  $STDOUT, %rdi
    leaq  minus(%rip), %rsi
    movq  $1, %rdx
    syscall
    negq  %rbx               # Unsigned, it is right
                             # even for -2^63.
print:
    movq  %rbx, %rdi
    leaq  output(%rip), %rsi
    movq  $10, %rdx
    call  integer2string_base
    movq  %rax, %rdx
    movq  $SYS_WRITE, %rax
    movq  $STDOUT, %rdi
    leaq  output(%rip), %rsi
    syscall
    movq  $STDOUT, %rdi
    call  write_newline
exit:
    movq  $SYS_EXIT, %rax
    movq  $0, %rdi
    syscall

    # PURPOSE:
    #     Convert decimal text to an integer.
    #     An optional '-' sign is accepted at the
    #     start; the conversion stops at the first
    #     character that is not a digit (such as the
    #     newline or the null byte).
    #
    # INPUT:
    #     %rdi - Address of the text.
    #
    # OUTPUT:
    #     %rax - The integer.
    #
    # VARIABLES:
    #     %rax - Result so far.
    #     %rdi - Address of the current character.
    #     %rcx - Current character / digit value.
    #     %rdx - 1 if the number is negative.
    #
        .globl number2integer
        .type  number2integer, @function
number2integer:
    pushq %rbp
    movq  %rsp, %rbp
    movq  $0, %rax
    movq  $0, %rdx
    cmpb  $'-', (%rdi)       # Sign?
    jne   digit_loop
    movq  $1, %rdx
    incq  %rdi
digit_loop:
    movzbq (%rdi), %rcx      # Byte -> 64 bits.
    subq  $'0', %rcx         # '0'..'9' -> 0..9.
    cmpq  $9, %rcx           # Not a digit? (Also
    ja    digits_end         # catches < '0'.)
    imulq $10, %rax          # result = result*10
    addq  %rcx, %rax         #          + digit
    incq  %rdi
    jmp   digit_loop
digits_end:
    cmpq  $1, %rdx
    jne   number_end
    negq  %rax               # Apply the sign.
number_end:
    movq  %rbp, %rsp
    popq  %rbp
    ret
