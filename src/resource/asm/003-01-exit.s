    # PURPOSE:    Simple program that exits and returns
    #             a status code back to the Linux
    #             kernel.
    #
    # INPUT:      None.
    #
    # OUTPUT:     Returns a status code.  This can be
    #             viewed by typing `echo $?` after
    #             running the program.
    #
    # VARIABLES:
    #             %rax holds the system call number.
    #             %rdi holds the return status.
    #
    .section .note.GNU-stack,"",@progbits

    .section .data

    .section .text
        .globl _start

_start:
    movq $60, %rax     # This is the Linux kernel
                       # command number (system call)
                       # for exiting a program.

    movq $0, %rdi      # This is the status number we
                       # will return to the operating
                       # system. Change this around and
                       # it will return different
                       # things to `echo $?`.

    syscall            # This wakes up the kernel to
                       # run the exit command.
