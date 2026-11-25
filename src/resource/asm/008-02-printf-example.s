    # PURPOSE:
    #     This program is to demonstrate how to call
    #     printf.
    #
    .section .note.GNU-stack,"",@progbits

    .section .data
        # This string is called the format string. It
        # is the first parameter, and printf uses it to
        # find out how many parameters it was given,
        # and what kind they are.
        #
        first_string:
            .ascii "Hi! %s is the %s number #%ld.\n\0"

        name_string:
            .ascii "Jonathan\0"

        person_string:
            .ascii "person\0"

        # This could also have been an .equ, but we
        # decided to give it a real memory location
        # just for kicks.
        #
        number_loved:
            .quad 3

    .section .text
        .globl _start

_start:
    # The parameters go in the registers of the
    # calling convention, in the same order as in
    # the function prototype.
    #
    leaq  first_string(%rip), %rdi
                            # The format string.
    leaq  name_string(%rip), %rsi
                            # This is the first %s.
    leaq  person_string(%rip), %rdx
                            # This is the second %s.
    movq  number_loved(%rip), %rcx
                            # This is the %ld.
    movq  $0, %rax          # printf takes a variable
                            # number of parameters: %al
                            # says how many are in
                            # vector registers (none).
    call  printf@PLT

    movq  $0, %rdi
    call  exit@PLT
