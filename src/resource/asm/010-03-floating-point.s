    # PURPOSE:
    #     Show how floating-point numbers behave, with
    #     the SSE2 instructions, and print them with
    #     printf.
    #
    # OUTPUT:
    #     16777216 + 1 = 16777216.0 (float)
    #     16777216 + 1 = 16777217.0 (double)
    #     0.1 + 0.2 = 0.30000000000000004
    #     7 / 2 = 3.5, truncated to 3
    #
    .section .note.GNU-stack,"",@progbits

    .section .data
        big_float:          # 4 bytes each.
            .float 16777216.0
        one_float:
            .float 1.0

        big_double:         # 8 bytes each.
            .double 16777216.0
        one_double:
            .double 1.0
        tenth:
            .double 0.1
        fifth:
            .double 0.2

        format_float:
            .ascii "16777216 + 1 = %.1f (float)\n\0"
        format_double:
            .ascii "16777216 + 1 = %.1f (double)\n\0"
        format_sum:
            .ascii "0.1 + 0.2 = %.17g\n\0"
        format_divide:
            .ascii "7 / 2 = %.1f, truncated to %ld\n\0"

    .section .text
        .globl _start

_start:
    # A float can't hold 16777217: the sum is rounded
    # back to 16777216.
    movss    big_float(%rip), %xmm0
    addss    one_float(%rip), %xmm0
    cvtss2sd %xmm0, %xmm0   # printf takes doubles.
    leaq     format_float(%rip), %rdi
    movq     $1, %rax       # One vector register.
    call     printf@PLT

    # A double has room for it.
    movsd    big_double(%rip), %xmm0
    addsd    one_double(%rip), %xmm0
    leaq     format_double(%rip), %rdi
    movq     $1, %rax
    call     printf@PLT

    # 0.1 and 0.2 have no exact binary form.
    movsd    tenth(%rip), %xmm0
    addsd    fifth(%rip), %xmm0
    leaq     format_sum(%rip), %rdi
    movq     $1, %rax
    call     printf@PLT

    # From integers to floating point and back.
    movq     $7, %rax
    cvtsi2sdq %rax, %xmm0   # %xmm0 = 7.0
    movq     $2, %rax
    cvtsi2sdq %rax, %xmm1   # %xmm1 = 2.0
    divsd    %xmm1, %xmm0   # %xmm0 = 7.0 / 2.0
    cvttsd2si %xmm0, %rsi   # %rsi = 3 (truncated)
    leaq     format_divide(%rip), %rdi
    movq     $1, %rax       # %xmm0; %rsi is not a
    call     printf@PLT     # vector register.

    movq     $0, %rdi
    call     exit@PLT
