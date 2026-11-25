    # PURPOSE:
    #     Solution to Chapter 10, "Use the Concepts"
    #     and "Going Further": `integer2string` with
    #     the base as a parameter, from 2 to 36.
    #     Digits past 9 are the letters a to z, so
    #     base 8 gives octal and base 16 gives
    #     hexadecimal.
    #
    # INPUT:
    #     %rdi - The (unsigned) number.
    #     %rsi - Buffer for the text (65 bytes is
    #            enough for any base: 64 digits and
    #            a null byte).
    #     %rdx - The base (2 to 36).
    #
    # OUTPUT:
    #     The buffer holds the null-terminated text.
    #     %rax - Number of characters written.
    #
    .section .note.GNU-stack,"",@progbits

    .section .rodata
        digits:
            .ascii "0123456789"
            .ascii "abcdefghijklmnopqrstuvwxyz"

    .section .text
        .globl integer2string_base
        .type  integer2string_base, @function
integer2string_base:
    pushq %rbp
    movq  %rsp, %rbp

    movq  %rdx, %r8          # The base: divq uses
                             # %rdx.
    movq  %rdi, %rax
    leaq  digits(%rip), %r9
    movq  $0, %rcx           # Digit count.
conversion_loop:
    movq  $0, %rdx           # %rdx:%rax / base:
    divq  %r8                # %rax = quotient,
                             # %rdx = remainder.
    movzbq (%r9,%rdx), %rdx  # Remainder -> digit.
    pushq %rdx               # Digits come out in
    incq  %rcx               # reverse order, so use
    cmpq  $0, %rax           # the stack to reverse
    jne   conversion_loop    # them.

    movq  %rcx, %rax         # Return the count.
copy_loop:
    popq  %rdx
    movb  %dl, (%rsi)
    incq  %rsi
    decq  %rcx
    jnz   copy_loop
    movb  $0, (%rsi)         # Null terminator.

    movq  %rbp, %rsp
    popq  %rbp
    ret
