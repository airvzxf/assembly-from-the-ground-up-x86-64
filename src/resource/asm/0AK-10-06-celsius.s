    # PURPOSE:
    #     Solution to Chapter 10, "Use the Concepts":
    #     a function that converts a temperature from
    #     Fahrenheit to Celsius with SSE2, and a
    #     program that prints a few with printf.
    #
    # OUTPUT:
    #     -40.0 F = -40.0 C
    #     32.0 F = 0.0 C
    #     98.6 F = 37.0 C
    #     212.0 F = 100.0 C
    #
    .section .note.GNU-stack,"",@progbits

    .section .rodata
        temperatures:
            .double -40.0, 32.0, 98.6, 212.0
        temperatures_end:
        format:
            .ascii "%.1f F = %.1f C\n\0"
        thirty_two:
            .double 32.0
        five:
            .double 5.0
        nine:
            .double 9.0

    .section .text
        .globl _start
_start:
    leaq  temperatures(%rip), %rbx
    leaq  temperatures_end(%rip), %r12
print_loop:
    cmpq  %r12, %rbx
    je    print_end
    movsd (%rbx), %xmm0      # celsius(f)
    call  celsius
    movsd %xmm0, %xmm1       # printf(format, f, c)
    movsd (%rbx), %xmm0
    leaq  format(%rip), %rdi
    movq  $2, %rax           # Two vector registers.
    call  printf@PLT
    addq  $8, %rbx           # Next double.
    jmp   print_loop
print_end:
    movq  $0, %rdi
    call  exit@PLT

    # PURPOSE:
    #     Convert Fahrenheit to Celsius:
    #     c = (f - 32) * 5 / 9.
    #
    # INPUT:
    #     %xmm0 - Degrees Fahrenheit (double).
    #
    # OUTPUT:
    #     %xmm0 - Degrees Celsius (double).
    #
        .globl celsius
        .type  celsius, @function
celsius:
    subsd thirty_two(%rip), %xmm0
    mulsd five(%rip), %xmm0
    divsd nine(%rip), %xmm0
    ret
