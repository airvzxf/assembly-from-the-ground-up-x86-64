    # Link with `009-02-alloc.o`.
    #
    # PURPOSE:
    #     Call the `allocate` function of Chapter 9
    #     many times, without freeing anything, to
    #     measure it with `perf` (Chapter 12). Each
    #     call looks at every region that the
    #     previous calls created.
    #
    # OUTPUT:
    #     Exit status code 0, or 1 if allocate
    #     failed.
    #
    .section .note.GNU-stack,"",@progbits

    .include "006-01-linux.s"

        .equ COUNT, 20000    # Number of allocations.
        .equ SIZE,  16       # Bytes in each one.

    .section .text
        .globl _start
_start:
    call  allocate_init
    movq  $COUNT, %rbx       # Allocations left.

allocate_loop:
    movq  $SIZE, %rdi
    call  allocate
    cmpq  $0, %rax
    je    failed
    decq  %rbx
    jnz   allocate_loop

    movq  $SYS_EXIT, %rax
    movq  $0, %rdi
    syscall

failed:
    movq  $SYS_EXIT, %rax
    movq  $1, %rdi
    syscall
