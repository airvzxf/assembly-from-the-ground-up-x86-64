    # PURPOSE:
    #     Solution to Chapter 3, "Use the Concepts":
    #     find the maximum number of a set of data
    #     items. A 255 terminates the data, so 0 is
    #     now a valid item.
    #
    # VARIABLES:
    #     %rbx - Address of the first data item.
    #     %rcx - Index of the data item being examined.
    #     %rdi - Largest data item found.
    #     %rax - Current data item.
    #
    .section .note.GNU-stack,"",@progbits

    .section .data
        data_items:
            .quad 3, 67, 34, 0, 45, 22, 11, 125, 255

    .section .text
        .globl _start

_start:
    leaq data_items(%rip), %rbx
    movq $0, %rcx            # Start at index 0.
    movq (%rbx,%rcx,8), %rax
    movq %rax, %rdi          # The first item is the
                             # largest so far.

_start_loop:
    incq %rcx                # Load the next item.
    movq (%rbx,%rcx,8), %rax
    cmpq $255, %rax          # End of the list?
    je   _loop_exit          # (Checked first, or
                             # 255 would win.)
    cmpq %rdi, %rax
    jle  _start_loop
    movq %rax, %rdi          # New largest value.
    jmp  _start_loop

_loop_exit:
    movq $60, %rax           # exit(); %rdi holds
    syscall                  # the maximum.
