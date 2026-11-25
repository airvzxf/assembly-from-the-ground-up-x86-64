    # PURPOSE:
    #     Solution to Chapter 9, "Use the Concepts":
    #     the memory manager of `009-02-alloc.s` with
    #     two improvements:
    #     1. `allocate` calls `allocate_init` by
    #        itself the first time.
    #     2. When the chosen free region is bigger
    #        than needed, it is split in two: the part
    #        that is used and a new free region with
    #        its own header.
    #
    # MEMORY LAYOUT OF A REGION:
    #     | available | size | size bytes of memory |
    #       8 bytes    8 bytes  ^-- returned pointer
    #
    #     Sizes are multiples of 16, so every header
    #     and every returned pointer is too.
    #
    .section .note.GNU-stack,"",@progbits

    .include "006-01-linux.s"

    .section .data
        heap_begin:
            .quad 0
        current_break:
            .quad 0

        .equ HEADER_SIZE,      16
        .equ HDR_AVAIL_OFFSET, 0
        .equ HDR_SIZE_OFFSET,  8
        .equ UNAVAILABLE,      0
        .equ AVAILABLE,        1
        # Split only if the free part can hold a
        # header and at least this many bytes.
        .equ MIN_SPLIT,        16

    .section .text
    # PURPOSE:
    #     Set heap_begin and current_break to the
    #     current break, rounded up to 16.
    #
        .globl allocate_init
        .type  allocate_init, @function
allocate_init:
    pushq %rbp
    movq  %rsp, %rbp
    movq  $SYS_BRK, %rax     # brk(0) returns the
    movq  $0, %rdi           # current break.
    syscall
    addq  $15, %rax
    andq  $-16, %rax
    movq  %rax, current_break(%rip)
    movq  %rax, heap_begin(%rip)
    movq  %rbp, %rsp
    popq  %rbp
    ret

    # PURPOSE:
    #     Reserve memory.
    #
    # INPUT:
    #     %rdi - Number of bytes wanted.
    #
    # OUTPUT:
    #     %rax - Address of the memory, or 0 if
    #     there is no memory available.
    #
    # VARIABLES:
    #     %rdx - Size requested, rounded up to 16.
    #     %rax - Region being examined.
    #     %rsi - Current break.
    #     %r8  - Size of the region being examined.
    #     %r9  - Size of the new free region (split),
    #            or the new region (move_break).
    #
        .globl allocate
        .type  allocate, @function
allocate:
    pushq %rbp
    movq  %rsp, %rbp
    subq  $16, %rsp
    cmpq  $0, heap_begin(%rip)  # Improvement 1:
    jne   initialized           # initialize on the
    movq  %rdi, -8(%rbp)        # first call. Keep
    call  allocate_init         # the size across
    movq  -8(%rbp), %rdi        # the call.
initialized:
    leaq  15(%rdi), %rdx
    andq  $-16, %rdx
    movq  heap_begin(%rip), %rax
    movq  current_break(%rip), %rsi
alloc_loop_begin:
    cmpq  %rsi, %rax         # End of the heap?
    je    move_break
    movq  HDR_SIZE_OFFSET(%rax), %r8
    cmpq  $UNAVAILABLE, HDR_AVAIL_OFFSET(%rax)
    je    next_location      # Region in use.
    cmpq  %r8, %rdx          # Big enough?
    jbe   allocate_here
next_location:
    addq  $HEADER_SIZE, %rax
    addq  %r8, %rax
    jmp   alloc_loop_begin
allocate_here:
    # Improvement 2: split the region if the rest
    # (size - requested - header) is big enough.
    movq  %r8, %r9
    subq  %rdx, %r9          # %r9 = what is left.
    cmpq  $HEADER_SIZE + MIN_SPLIT, %r9
    jb    mark_used
    subq  $HEADER_SIZE, %r9  # Size of the new free
                             # region.
    movq  %rdx, HDR_SIZE_OFFSET(%rax)
    leaq  HEADER_SIZE(%rax,%rdx), %r8
    movq  $AVAILABLE, HDR_AVAIL_OFFSET(%r8)
    movq  %r9, HDR_SIZE_OFFSET(%r8)
mark_used:
    movq  $UNAVAILABLE, HDR_AVAIL_OFFSET(%rax)
    addq  $HEADER_SIZE, %rax
    jmp   allocate_return
move_break:
    # Grow the heap by header + requested size.
    movq  %rax, %r9          # New region.
    leaq  HEADER_SIZE(%rsi,%rdx), %rdi
    movq  $SYS_BRK, %rax
    syscall
    cmpq  %rdi, %rax         # brk returns the old
    jne   error              # break on failure.
    movq  $UNAVAILABLE, HDR_AVAIL_OFFSET(%r9)
    movq  %rdx, HDR_SIZE_OFFSET(%r9)
    movq  %rdi, current_break(%rip)
    leaq  HEADER_SIZE(%r9), %rax
    jmp   allocate_return
error:
    movq  $0, %rax
allocate_return:
    movq  %rbp, %rsp
    popq  %rbp
    ret

    # PURPOSE:
    #     Give back memory reserved by allocate.
    #
    # INPUT:
    #     %rdi - Address returned by allocate.
    #
        .globl deallocate
        .type  deallocate, @function
deallocate:
    subq  $HEADER_SIZE, %rdi
    movq  $AVAILABLE, HDR_AVAIL_OFFSET(%rdi)
    ret
