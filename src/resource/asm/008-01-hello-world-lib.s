    # PURPOSE:
    #     This program writes the message "hello world"
    #     and exits, using the C library.
    #
    .section .note.GNU-stack,"",@progbits

    .section .data
        helloworld:
            .ascii "hello world\n\0"

    .section .text
        .globl _start

_start:
    leaq  helloworld(%rip), %rdi
    movq  $0, %rax          # No vector registers.
    call  printf@PLT

    movq  $0, %rdi
    call  exit@PLT
