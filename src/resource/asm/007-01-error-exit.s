    # PURPOSE:
    #     Write an error code and an error message to
    #     STDERR, and exit with status 1.
    #
    # INPUT:
    #     %rdi - The address of the error code (a
    #            null-terminated string).
    #     %rsi - The address of the error message (a
    #            null-terminated string).
    #
    # OUTPUT:
    #     It never returns.
    #
    .section .note.GNU-stack,"",@progbits

    .include "006-01-linux.s"      # Linux Definitions.

    .section .text
        .globl error_exit
        .type  error_exit,   @function

error_exit:
    pushq %rbp
    movq  %rsp, %rbp
    pushq %rbx              # Keep the parameters in
    pushq %r12              # callee-saved registers:
    movq  %rdi, %rbx        # count_chars may change
    movq  %rsi, %r12        # %rdi and %rsi.

                            # Write out error code.
    movq  %rbx, %rdi
    call  count_chars
    movq  %rax, %rdx
    movq  %rbx, %rsi
    movq  $STDERR, %rdi
    movq  $SYS_WRITE, %rax
    syscall

                            # Write out error message.
    movq  %r12, %rdi
    call  count_chars
    movq  %rax, %rdx
    movq  %r12, %rsi
    movq  $STDERR, %rdi
    movq  $SYS_WRITE, %rax
    syscall

    movq  $STDERR, %rdi
    call  write_newline

                            # Exit with status 1.
    movq  $SYS_EXIT, %rax
    movq  $1, %rdi
    syscall
