    # Build the shared library with:
    #     ld -shared -o libexitmsg.so \
    #       0AK-08-04-exit-message.o
    # Use it with a program linked with the C
    # library:
    #     LD_PRELOAD=./libexitmsg.so \
    #       ./008-02-printf-example
    #
    # PURPOSE:
    #     Solution to Chapter 8, "Going Further": a
    #     shared library with its own `exit` function.
    #     With LD_PRELOAD, the dynamic linker finds
    #     this `exit` before the one in the C
    #     library, so every call to `exit` writes a
    #     message to STDERR first.
    #
    # NOTES:
    #     This `exit` doesn't flush the C library
    #     buffers, so text that `printf` wrote may be
    #     lost. The message is local to the library
    #     and is reached relative to %rip.
    #
    .section .note.GNU-stack,"",@progbits

    .include "006-01-linux.s"

    .section .rodata
        message:
            .ascii "exit() called: bye!\n"
        message_end:
            .equ MESSAGE_LEN, message_end - message

    .section .text
        .globl exit
        .type  exit, @function
exit:
    movq  %rdi, %rbx         # The status. This
                             # function never returns.
    movq  $SYS_WRITE, %rax
    movq  $STDERR, %rdi
    leaq  message(%rip), %rsi
    movq  $MESSAGE_LEN, %rdx
    syscall

    movq  $SYS_EXIT, %rax
    movq  %rbx, %rdi         # exit(status)
    syscall
