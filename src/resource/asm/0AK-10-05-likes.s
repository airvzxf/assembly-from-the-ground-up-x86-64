    # PURPOSE:
    #     Solution to Chapter 10, "Going Further":
    #     store likes and dislikes in a single
    #     quadword and compare two people.
    #
    # LAYOUT OF THE QUADWORD:
    #     Bits 0 to 31  - Likes.
    #     Bits 32 to 63 - Dislikes, same order.
    #
    # OUTPUT:
    #     Exit status code: shared likes * 10 +
    #     shared dislikes. For the people below:
    #     books and games (2), sports (1) -> 21.
    #
    .section .note.GNU-stack,"",@progbits

    .include "006-01-linux.s"

        .equ MUSIC,   1 << 0
        .equ BOOKS,   1 << 1
        .equ MOVIES,  1 << 2
        .equ SPORTS,  1 << 3
        .equ COOKING, 1 << 4
        .equ GAMES,   1 << 5
        .equ ART,     1 << 6
        .equ DISLIKE, 32     # Shift for dislikes.

    .section .data
        .equ A_LIKES,    MUSIC | BOOKS | GAMES
        .equ A_DISLIKES, SPORTS | COOKING
        .equ B_LIKES,    BOOKS | GAMES | ART
        .equ B_DISLIKES, SPORTS | MOVIES
        person_a:
            .quad A_LIKES | (A_DISLIKES << DISLIKE)
        person_b:
            .quad B_LIKES | (B_DISLIKES << DISLIKE)

    .section .text
        .globl _start
_start:
    movq  person_a(%rip), %rbx
    andq  person_b(%rip), %rbx  # Bits set in both.

    movl  %ebx, %edi         # Shared likes only:
    call  count_bits         # writing %edi clears
    imulq $10, %rax, %r12    # the upper half of
                             # %rdi.
    movq  %rbx, %rdi
    shrq  $DISLIKE, %rdi     # Shared dislikes.
    call  count_bits
    addq  %rax, %r12

    movq  $SYS_EXIT, %rax
    movq  %r12, %rdi
    syscall

    # PURPOSE:
    #     Count the bits set to 1 in a quadword.
    #
    # INPUT:
    #     %rdi - The quadword.
    #
    # OUTPUT:
    #     %rax - Number of bits set.
    #
    # NOTES:
    #     Processors since 2008 have an instruction
    #     that does all of this: popcntq %rdi, %rax.
    #
        .type count_bits, @function
count_bits:
    movq  $0, %rax
count_loop:
    cmpq  $0, %rdi
    je    count_end
    testq $1, %rdi           # Lowest bit set?
    jz    count_next
    incq  %rax
count_next:
    shrq  $1, %rdi           # Next bit.
    jmp   count_loop
count_end:
    ret
