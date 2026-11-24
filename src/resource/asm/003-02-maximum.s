    # PURPOSE:
    #     This program finds the maximum number of a
    #     set of data items.
    #
    # VARIABLES:
    #     The registers have the following uses:
    #       %rbx - Address of the first data item.
    #       %rcx - Index of the data item being
    #              examined.
    #       %rdi - Largest data item found.
    #       %rax - Current data item.
    #
    # The following memory locations are used:
    #     data_items - contains the item data.  A 0 is
    #                  used to terminate the data.
    #
    .section .note.GNU-stack,"",@progbits

    .section .data
        data_items:         # These are the data items.
            .quad 3, 67, 34, 222, 45, 22, 11, 125, 0

    .section .text
        .globl _start

_start:
    leaq data_items(%rip), %rbx  # Address of the
                                 # list.
    movq $0, %rcx           # Move 0 into the index
                            # register.
    movq (%rbx,%rcx,8), %rax  # Load the first
                              # data item.
    movq %rax, %rdi         # Since this is the first
                            # item, %rax is the biggest

_start_loop:                # Start loop.
    cmpq $0, %rax           # Check to see if we have
    je _loop_exit           # hit the end.
    incq %rcx               # Increment %rcx by 1.
    movq (%rbx,%rcx,8), %rax  # Load next value.
    cmpq %rdi, %rax         # Compare values.
    jle _start_loop         # Jump to loop beginning if
                            # the new one is not bigger
    movq %rax, %rdi         # Move the value as the
                            # largest.
    jmp _start_loop         # Jump to loop beginning.

_loop_exit:
                            # %rdi is the status code
                            # for the exit system call
    movq $60, %rax          # and it already has the
    syscall                 # maximum. 60 is the
                            # exit() system call.
