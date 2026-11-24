    # PURPOSE:
    #     Solution to Chapter 3, "Use the Concepts":
    #     find the maximum number of a set of data
    #     items, using a length count instead of a
    #     terminating number.
    #
    # VARIABLES:
    #     %rbx - Address of the first data item.
    #     %rcx - Index of the data item being examined.
    #     %rdi - Largest data item found.
    #     %rax - Current data item.
    #
    .section .note.GNU-stack,"",@progbits

    .section .data
        data_length:         # Number of items.
            .quad 8
        data_items:
            .quad 3, 67, 34, 222, 45, 22, 11, 125

    .section .text
        .globl _start

_start:
    leaq data_items(%rip), %rbx
    movq $0, %rcx            # Start at index 0.
    movq (%rbx,%rcx,8), %rdi
                             # The first item is the
                             # largest so far.

_start_loop:
    incq %rcx                # Next index.
    cmpq data_length(%rip), %rcx  # index == length?
    je   _loop_exit
    movq (%rbx,%rcx,8), %rax
    cmpq %rdi, %rax
    jle  _start_loop
    movq %rax, %rdi          # New largest value.
    jmp  _start_loop

_loop_exit:
    movq $60, %rax           # exit(); %rdi holds
    syscall                  # the maximum.
