    # PURPOSE:
    #     Solution to Chapter 4, "Going Further":
    #     a calling convention of our own. The
    #     parameters go on the stack instead of in
    #     registers, the caller removes them after
    #     the call, and the result comes back in
    #     %rax. It computes 2^3 + 5^2.
    #
    # OUTPUT:
    #     Exit status 33, like 004-01-power.
    #
    .section .note.GNU-stack,"",@progbits

    .section .data

    .section .text
        .globl _start

_start:
    pushq $3                 # Second parameter: the
                             # power.
    pushq $2                 # First parameter: the
                             # base.
    call  power              # 2^3
    addq  $16, %rsp          # Remove the parameters.
    movq  %rax, %rbx         # Save the result.

    pushq $2
    pushq $5
    call  power              # 5^2
    addq  $16, %rsp

    addq  %rax, %rbx         # 8 + 25
    movq  %rbx, %rdi
    movq  $60, %rax
    syscall

    # INPUT:   16(%rbp) - The base number.
    #          24(%rbp) - The power (0 or greater).
    # OUTPUT:  %rax - The base raised to the power.
    #
    .type power, @function
power:
    pushq %rbp
    movq  %rsp, %rbp

    movq  $1, %rax           # Result.
    movq  24(%rbp), %rcx     # Power, counting down.

power_loop:
    cmpq  $0, %rcx           # Done when power = 0.
    je    power_end
    imulq 16(%rbp), %rax     # Multiply by the base.
    decq  %rcx
    jmp   power_loop

power_end:
    movq  %rbp, %rsp
    popq  %rbp
    ret
