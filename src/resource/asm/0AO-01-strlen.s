    # PURPOSE:
    #     Four versions of the same function, from
    #     the simplest to the fastest: each returns
    #     the number of bytes before the first null
    #     byte of a string.
    #
    # INPUT:   %rdi - the address of the string.
    # OUTPUT:  %rax - its length.
    #
    # Built as a shared library, libstrlen.so, so
    # Python can test and time them (Appendix O).
    #
    .section .note.GNU-stack,"",@progbits

    .section .text

    # Version 1: the loop of count_chars (Chapter
    # 6), with a stack frame and an index.
    .globl strlen_v1
    .type strlen_v1, @function
strlen_v1:
    pushq %rbp
    movq  %rsp, %rbp
    movq  $0, %rcx          # The index.
v1_loop:
    movb  (%rdi,%rcx,1), %al  # Load a byte.
    cmpb  $0, %al
    je    v1_end
    incq  %rcx
    jmp   v1_loop
v1_end:
    movq  %rcx, %rax
    popq  %rbp
    ret

    # Version 2: no stack frame (it calls nothing),
    # a pointer instead of an index, the test at the
    # end of the loop so there is one jump per byte,
    # and the length computed at the end.
    .globl strlen_v2
    .type strlen_v2, @function
strlen_v2:
    leaq  -1(%rdi), %rax    # One before the start.
v2_loop:
    incq  %rax              # The next byte.
    cmpb  $0, (%rax)
    jne   v2_loop
    subq  %rdi, %rax        # End minus start.
    ret

    # Version 3: one string instruction does the
    # loop (see Appendix B).
    .globl strlen_v3
    .type strlen_v3, @function
strlen_v3:
    xorl  %eax, %eax        # Look for the byte 0,
    movq  $-1, %rcx         # with no limit.
    repne scasb             # Advances %rdi and
                            # counts %rcx down.
    notq  %rcx              # -2 - length becomes
    leaq  -1(%rcx), %rax    # length + 1, minus 1.
    ret

    # Version 4: SSE2, 16 bytes at a time. Each
    # read is aligned to 16 bytes, so it never
    # crosses into the next page of memory, which
    # might not exist.
    .globl strlen_v4
    .type strlen_v4, @function
strlen_v4:
    movq  %rdi, %rax
    andq  $-16, %rax        # The aligned block that
                            # holds the first byte.
    pxor  %xmm0, %xmm0      # 16 zero bytes.
    movdqa (%rax), %xmm1
    pcmpeqb %xmm0, %xmm1    # 0xff where a byte is 0.
    pmovmskb %xmm1, %edx    # One bit per byte.
    movl  %edi, %ecx
    andl  $15, %ecx         # Bytes of the block
    shrl  %cl, %edx         # before the string: drop
    testl %edx, %edx        # their bits.
    jnz   v4_first
v4_loop:
    addq  $16, %rax         # The next block.
    movdqa (%rax), %xmm1
    pcmpeqb %xmm0, %xmm1
    pmovmskb %xmm1, %edx
    testl %edx, %edx
    jz    v4_loop
    bsfl  %edx, %edx        # The first 0 in the
    addq  %rdx, %rax        # block.
    subq  %rdi, %rax        # End minus start.
    ret
v4_first:
    bsfl  %edx, %eax        # The 0 is in the first
    ret                     # block.
