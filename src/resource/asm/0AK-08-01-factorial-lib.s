    # Build the shared library with:
    #     as --64 -g -o 0AK-08-01-factorial-lib.o \
    #       0AK-08-01-factorial-lib.s
    #     ld -shared -o libfactorial.so \
    #       0AK-08-01-factorial-lib.o
    #
    # PURPOSE:
    #     Solution to Chapter 8, "Use the Concepts":
    #     the recursive `factorial` function of
    #     Chapter 4, alone in a file, to build the
    #     shared library `libfactorial.so`.
    #
    # INPUT:
    #     %rdi - n.
    #
    # OUTPUT:
    #     %rax - n! (1 for 0 and 1).
    #
    # NOTES:
    #     `factorial` is global, so the recursive call
    #     goes through the PLT, like a call from a
    #     program: another library loaded first (for
    #     example with LD_PRELOAD) could replace it.
    #
    .section .note.GNU-stack,"",@progbits

    .section .text
        .globl factorial
        .type  factorial, @function
factorial:
    pushq %rbp
    movq  %rsp, %rbp
    subq  $16, %rsp          # One local variable.

    movq  $1, %rax
    cmpq  $1, %rdi           # 1! = 1 (and 0! = 1).
    jle   end_factorial

    movq  %rdi, -8(%rbp)     # Save n.
    decq  %rdi
    call  factorial@PLT      # (n - 1)!
    imulq -8(%rbp), %rax     # n * (n - 1)!

end_factorial:
    movq  %rbp, %rsp
    popq  %rbp
    ret
