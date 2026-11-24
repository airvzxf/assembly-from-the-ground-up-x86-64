    # PURPOSE:
    #     Program to illustrate how functions work.
    #     This program will compute the value of
    #     2^3 + 5^2
    #
    # Everything in the main program is stored in
    # registers, so the data section does not have
    # anything.
    #
    .section .note.GNU-stack,"",@progbits

    .section .data

    .section .text
        .globl _start

_start:
    movq $2, %rdi           # First argument: the base.
    movq $3, %rsi           # Second argument: the
                            # power.
    call power              # Call the function.

    movq %rax, %rbx         # Save the first answer
                            # in %rbx, which every
                            # function must preserve.

    movq $5, %rdi           # First argument.
    movq $2, %rsi           # Second argument.
    call power              # Call the function.

    addq %rax, %rbx         # Add the second answer
                            # to the first one.

    movq %rbx, %rdi         # The result is the
    movq $60, %rax          # status code. Exit.
    syscall

    # PURPOSE:
    #     This function is used to compute the value
    #     of a number raised to a power.
    #
    # INPUT:
    #     %rdi - The base number.
    #     %rsi - The power to raise it to.
    #
    # OUTPUT:
    #     Will give the result as a return value
    #     in %rax.
    #
    # NOTES:
    #     The power must be 1 or greater.
    #
    # VARIABLES:
    #     %rdi - Holds the base number.
    #     %rsi - Holds the power, counting down.
    #     -8(%rbp) - Holds the current result.
    #     %rax - Is used for temporary storage.
    #
    .type power, @function

power:
    pushq %rbp              # Save old base pointer.
    movq  %rsp, %rbp        # Make stack pointer the
                            # base pointer.
    subq  $16, %rsp         # Get room for our local
                            # storage (8 bytes, plus
                            # 8 to keep %rsp aligned
                            # to 16).

    movq  %rdi, -8(%rbp)    # Store current result.

power_loop_start:
    cmpq  $1, %rsi          # If the power is 1, we
    je    end_power         # are done.
    movq  -8(%rbp), %rax    # Move the current result
                            # into %rax.
    imulq %rdi, %rax        # Multiply the current
                            # result by the base
                            # number.
    movq  %rax, -8(%rbp)    # Store the current
                            # result.
    decq  %rsi              # Decrease the power.
    jmp   power_loop_start  # Run for the next power.

end_power:
    movq  -8(%rbp), %rax    # Return value goes in
                            # %rax.
    movq  %rbp, %rsp        # Restore the stack
                            # pointer.
    popq  %rbp              # Restore the base
                            # pointer.
    ret
