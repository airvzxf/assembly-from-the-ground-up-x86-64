    # PURPOSE:
    #     The `convert_to_upper` function of
    #     `005-01-toupper`, in its own file so the
    #     Chapter 5 solutions can link it.
    #
    # INPUT:
    #     %rdi - Address of the buffer.
    #     %rsi - Length of the buffer.
    #
    # OUTPUT:
    #     The buffer is converted in place.
    #
    .section .note.GNU-stack,"",@progbits

        .equ LOWERCASE_A,       'a'
        .equ LOWERCASE_Z,       'z'
        .equ UPPER_CONVERSION,  'A' - 'a'

    .section .text
        .globl convert_to_upper
        .type  convert_to_upper, @function
convert_to_upper:
    pushq %rbp
    movq  %rsp, %rbp

    movq  $0, %rcx           # Offset in the buffer.
    cmpq  $0, %rsi           # Empty buffer?
    je    end_convert_loop

convert_loop:
    movb  (%rdi,%rcx,1), %al
    cmpb  $LOWERCASE_A, %al  # Only 'a' to 'z'.
    jl    next_byte
    cmpb  $LOWERCASE_Z, %al
    jg    next_byte
    addb  $UPPER_CONVERSION, %al
    movb  %al, (%rdi,%rcx,1)
next_byte:
    incq  %rcx
    cmpq  %rcx, %rsi
    jne   convert_loop

end_convert_loop:
    movq  %rbp, %rsp
    popq  %rbp
    ret
