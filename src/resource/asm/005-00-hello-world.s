    # PURPOSE:
    #     This program writes "Hello, World!" to the
    #     standard output and exits.
    #
    .section .note.GNU-stack,"",@progbits

    .section .data
        message:
            .ascii "Hello, World!\n"
        message_end:
            # The assembler computes the length: the
            # address of message_end minus the address
            # of message.
            .equ MESSAGE_LENGTH, message_end - message

    .section .text
        .globl _start

_start:
    movq  $1, %rax          # System call 1 is write.
    movq  $1, %rdi          # File descriptor 1 is the
                            # standard output, which is
                            # already open.
    leaq  message(%rip), %rsi  # Address of the bytes.
    movq  $MESSAGE_LENGTH, %rdx  # How many bytes.
    syscall                 # %rax gets the number of
                            # bytes written.

    movq  $60, %rax         # Exit with status 0.
    movq  $0, %rdi
    syscall
