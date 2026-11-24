    # PURPOSE:
    #     Solution to Chapter 3, "Use the Concepts":
    #     the first program, returning 3 instead of 0.
    #
    # OUTPUT:
    #     Exit status code 3. Check it with `echo $?`.
    #
    .section .note.GNU-stack,"",@progbits

    .section .data

    .section .text
        .globl _start

_start:
    movq $60, %rax     # exit() system call number.
    movq $3, %rdi      # Status code returned to the
                       # shell.
    syscall            # Call the kernel.
