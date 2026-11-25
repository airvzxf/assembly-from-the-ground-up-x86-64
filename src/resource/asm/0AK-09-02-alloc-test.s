    # Link with `0AK-09-01-alloc.o` (or with
    # `009-02-alloc.o` to compare).
    #
    # PURPOSE:
    #     Test a memory manager. The exit status is
    #     the sum of the checks that failed:
    #       1 - Two allocations overlap.
    #       2 - Freed memory is not reused.
    #       4 - The free region was not split, so a
    #           second small request grew the heap.
    #       8 - An address is not a multiple of 16.
    #     `0AK-09-01-alloc` returns 0; the book's
    #     manager returns 4, because it doesn't split.
    #
    # VARIABLES:
    #     %rbx = a, %r12 = b, %r13 = c,
    #     %r14 = failures,
    #     %r15 = all the addresses ORed together.
    #
    .section .note.GNU-stack,"",@progbits

    .include "006-01-linux.s"

    .section .text
        .globl _start
_start:
    movq  $0, %r14
    call  allocate_init
    movq  $100, %rdi         # a = allocate(100)
    call  allocate
    movq  %rax, %rbx
    movq  %rax, %r15
    movq  $100, %rdi         # b = allocate(100)
    call  allocate
    movq  %rax, %r12
    orq   %rax, %r15
    leaq  100(%rbx), %rax    # Check 1: b must not
    cmpq  %rax, %r12         # start before the end
    jae   check_reuse        # of a.
    addq  $1, %r14
check_reuse:
    movq  %rbx, %rdi         # deallocate(a)
    call  deallocate
    movq  $40, %rdi          # c = allocate(40)
    call  allocate
    movq  %rax, %r13
    orq   %rax, %r15
    cmpq  %rbx, %r13         # Check 2: c == a.
    je    check_split
    addq  $2, %r14
check_split:
    movq  $40, %rdi          # d = allocate(40)
    call  allocate
    orq   %rax, %r15
    cmpq  %r12, %rax         # Check 3: d must be
    jb    check_alignment    # in a's old region,
    addq  $4, %r14           # below b.
check_alignment:
    testq $15, %r15          # Check 4: the lowest 4
    jz    done               # bits of every address
    addq  $8, %r14           # are 0.
done:
    movq  $SYS_EXIT, %rax
    movq  %r14, %rdi
    syscall
