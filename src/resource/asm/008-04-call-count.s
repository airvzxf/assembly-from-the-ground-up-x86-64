    # PURPOSE:
    #     A function for a shared library that
    #     remembers how many times it was called.
    #
    # INPUT:
    #     None.
    #
    # OUTPUT:
    #     %rax - The number of calls, including this
    #            one (1 the first time).
    #
    # NOTES:
    #     `calls` is the library's own variable. It is
    #     not global, and the code reaches it relative
    #     to %rip, so the library works at any address.
    #
    .section .note.GNU-stack,"",@progbits

    .section .data
        calls:
            .quad 0

    .section .text
        .globl call_count
        .type  call_count, @function

call_count:
    pushq %rbp
    movq  %rsp, %rbp

    incq  calls(%rip)       # One more call.
    movq  calls(%rip), %rax # Return the total.

    movq  %rbp, %rsp
    popq  %rbp
    ret
