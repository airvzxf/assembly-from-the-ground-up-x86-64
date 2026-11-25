    # Link with `0AK-09-01-alloc.o`.
    #
    # PURPOSE:
    #     Allocate memory WITHOUT calling
    #     `allocate_init`, write to it and read it
    #     back. With the book's manager `allocate`
    #     fails and returns 0, because the heap was
    #     never initialized.
    #
    # OUTPUT:
    #     Exit status code 42 (255 if allocate
    #     failed).
    #
    .section .note.GNU-stack,"",@progbits

    .include "006-01-linux.s"

    .section .text
        .globl _start
_start:
    movq  $16, %rdi
    call  allocate           # No allocate_init.
    cmpq  $0, %rax
    je    failed
    movq  $42, (%rax)        # Use the memory.
    movq  (%rax), %rdi
    movq  $SYS_EXIT, %rax
    syscall
failed:
    movq  $SYS_EXIT, %rax
    movq  $255, %rdi
    syscall
