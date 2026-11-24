    # PURPOSE:
    #     Solution to Chapter 3, "Use the Concepts":
    #     find the maximum number of a set of data
    #     items, stopping at an ending address
    #     instead of a terminating number.
    #
    # VARIABLES:
    #     %rcx - Address of the data item examined.
    #     %rdx - Address of the end of the list.
    #     %rdi - Largest data item found.
    #     %rax - Current data item.
    #
    .section .note.GNU-stack,"",@progbits

    .section .data
        data_items:
            .quad 3, 67, 34, 222, 45, 22, 11, 125
        data_end:            # First address AFTER
                             # the last item.

    .section .text
        .globl _start

_start:
    leaq data_items(%rip), %rcx  # Address of item 0.
    leaq data_end(%rip), %rdx    # End of the list.
    movq (%rcx), %rdi        # The first item is the
                             # largest so far.

_start_loop:
    addq $8, %rcx            # Next item (8 bytes).
    cmpq %rdx, %rcx          # Past the last item?
    je   _loop_exit
    movq (%rcx), %rax        # Indirect addressing.
    cmpq %rdi, %rax
    jle  _start_loop
    movq %rax, %rdi          # New largest value.
    jmp  _start_loop

_loop_exit:
    movq $60, %rax           # exit(); %rdi holds
    syscall                  # the maximum.
