    # PURPOSE:
    #     Count the characters until a null byte is
    #     reached.
    #
    # INPUT:
    #     %rdi - The address of the character string.
    #
    # OUTPUT:
    #     Returns the count in %rax.
    #
    # PROCESS:
    #     Registers used:
    #       %rcx - character count.
    #       %al  - current character.
    #       %rdx - current character address.
    #
    .section .note.GNU-stack,"",@progbits

    .section .text
        .globl count_chars
        .type  count_chars,  @function

count_chars:
    pushq %rbp
    movq  %rsp, %rbp

    movq  $0, %rcx          # Counter starts at zero.
    movq  %rdi, %rdx        # Starting address of data.

count_loop_begin:
    movb  (%rdx), %al       # Grab the current
                            # character.

    cmpb  $0, %al           # Is it null?
    je    count_loop_end    # If yes, we are done.

    incq  %rcx              # Otherwise, increment the
    incq  %rdx              # counter and the pointer.
    jmp   count_loop_begin  # Go back to the beginning
                            # of the loop.

count_loop_end:
    movq  %rcx, %rax        # We are done.  Move the
                            # count into %rax and
                            # return.

    movq  %rbp, %rsp
    popq  %rbp
    ret
