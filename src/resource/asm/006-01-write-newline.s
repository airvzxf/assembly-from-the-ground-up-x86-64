    # PURPOSE:
    #     Write a newline character to a file
    #     descriptor.
    #
    # INPUT:
    #     %rdi - The file descriptor.
    #
    .section .note.GNU-stack,"",@progbits

    .include "006-01-linux.s"      # Linux Definitions.

    .section .data
        newline:
            .ascii "\n"

    .section .text
        .globl write_newline
        .type  write_newline,  @function

write_newline:
    pushq %rbp
    movq  %rsp, %rbp

    movq  $SYS_WRITE, %rax  # The file descriptor is
    leaq  newline(%rip), %rsi   # already in %rdi.
    movq  $1, %rdx
    syscall

    movq  %rbp, %rsp
    popq  %rbp
    ret
