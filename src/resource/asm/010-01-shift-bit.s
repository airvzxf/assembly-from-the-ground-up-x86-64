    # PURPOSE:
    #     Find out from a set of flags whether my Dad
    #     likes dressy clothes (the second bit from
    #     the right), and say it.
    #
    .section .note.GNU-stack,"",@progbits

    .include "006-01-linux.s"      # Linux Definitions.

    .section .data
        yes_message:
            .ascii "He likes dressy clothes.\n"
        yes_end:
        no_message:
            .ascii "He doesn't like dressy clothes.\n"
        no_end:

    .section .text
        .globl _start

_start:
    movq  $0b1011, %rbx     # Food, heavy metal music,
                            # dressy clothes, football.

                # This is the shift operator. It stands
                # for Shift Right Quadword. This first
                # number is the number of positions to
                # shift, and the second is the register
                # to shift.
    shrq  $1, %rbx

                # This does the masking.
    andq  $0b0001, %rbx

                # Check to see if the result is 1 or 0.
    cmpq  $0b0001, %rbx
    je    yes_he_likes_dressy_clothes
    jmp   no_he_doesnt_like_dressy_clothes

yes_he_likes_dressy_clothes:
    leaq  yes_message(%rip), %rsi
    movq  $yes_end - yes_message, %rdx
    jmp   write_message

no_he_doesnt_like_dressy_clothes:
    leaq  no_message(%rip), %rsi
    movq  $no_end - no_message, %rdx

write_message:
    movq  $SYS_WRITE, %rax
    movq  $STDOUT, %rdi
    syscall

    movq  $SYS_EXIT, %rax
    movq  $0, %rdi
    syscall
