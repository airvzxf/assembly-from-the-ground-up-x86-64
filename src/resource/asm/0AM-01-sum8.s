    # PURPOSE:
    #     Call a function with eight parameters: the
    #     first six travel in registers and the last
    #     two on the stack. The exit status is the
    #     sum, 1 + 2 + ... + 8 = 36.
    #
    .section .note.GNU-stack,"",@progbits

    .section .text
        .globl _start

_start:
    # %rsp is a multiple of 16 here. Two pushes of 8
    # bytes keep it a multiple of 16 for the call.
    pushq $8                # 8th parameter, pushed
                            # first.
    pushq $7                # 7th parameter.
    movq  $1, %rdi          # 1st to 6th parameters.
    movq  $2, %rsi
    movq  $3, %rdx
    movq  $4, %rcx
    movq  $5, %r8
    movq  $6, %r9
    call  sum8
    addq  $16, %rsp         # The caller removes the
                            # parameters it pushed.

    movq  %rax, %rdi        # The sum is the status.
    movq  $60, %rax
    syscall

    # sum8(a, b, c, d, e, f, g, h): return the sum
    # of its eight parameters.
    .type sum8, @function
sum8:
    pushq %rbp
    movq  %rsp, %rbp
    movq  %rdi, %rax        # a
    addq  %rsi, %rax        # + b
    addq  %rdx, %rax        # + c
    addq  %rcx, %rax        # + d
    addq  %r8, %rax         # + e
    addq  %r9, %rax         # + f
    addq  16(%rbp), %rax    # + g, above the return
                            # address
    addq  24(%rbp), %rax    # + h
    popq  %rbp
    ret
