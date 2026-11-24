    # PURPOSE:
    #     Solution to Chapter 3, "Use the Concepts":
    #     find the minimum number of a set of data
    #     items. A 0 terminates the data.
    #
    # VARIABLES:
    #     %rbx - Address of the first data item.
    #     %rcx - Index of the data item being examined.
    #     %rdi - Smallest data item found.
    #     %rax - Current data item.
    #
    # NOTE:
    #     The terminator must be checked BEFORE the
    #     comparison. Otherwise the final 0 would be
    #     taken as the smallest number of the list.
    #
    .section .note.GNU-stack,"",@progbits

    .section .data
        data_items:
            .quad 3, 67, 34, 222, 45, 22, 11, 125, 0

    .section .text
        .globl _start

_start:
    leaq data_items(%rip), %rbx
    movq $0, %rcx            # Start at index 0.
    movq (%rbx,%rcx,8), %rax
    movq %rax, %rdi          # The first item is the
                             # smallest so far.

_start_loop:
    incq %rcx                # Load the next item.
    movq (%rbx,%rcx,8), %rax
    cmpq $0, %rax            # End of the list?
    je   _loop_exit
    cmpq %rdi, %rax          # Compare with the
    jge  _start_loop         # smallest; skip it if
                             # it is not smaller.
    movq %rax, %rdi          # New smallest value.
    jmp  _start_loop

_loop_exit:
    movq $60, %rax           # exit(); %rdi holds
    syscall                  # the minimum.
