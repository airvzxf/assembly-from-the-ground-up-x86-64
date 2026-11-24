    # PURPOSE:
    #     Given a number, this program computes the
    #     factorial. For example, the factorial of 3
    #     is 3 * 2 * 1, or 6. The factorial of 4 is
    #     4 * 3 * 2 * 1, or 24, and so on.
    #
    # This program shows how to call a function
    # recursively.
    #
    .section .note.GNU-stack,"",@progbits

    .section .data
    # This program has no global data.

    .section .text
        .globl _start
        .globl factorial    # This is unneeded unless
                            # we want to share this
                            # function among other
                            # programs.

_start:
    movq $4, %rdi           # The factorial takes one
                            # argument - the number we
                            # want a factorial of. It
                            # goes in %rdi.
    call factorial          # Run the factorial
                            # function.

    movq %rax, %rdi         # factorial returns the
                            # answer in %rax, but we
                            # want it in %rdi to send
                            # it as our exit status.
    movq $60, %rax          # Call the kernel's exit
    syscall                 # function.

    # This is the actual function definition.
    #
    # INPUT:  %rdi - The number.
    # OUTPUT: %rax - Its factorial.
    #
    .type factorial, @function
factorial:
    pushq %rbp              # Standard function stuff
                            # - we have to restore
                            # %rbp to its prior state
                            # before returning, so we
                            # have to push it.
    movq  %rsp, %rbp        # This is because we don't
                            # want to modify the stack
                            # pointer, so we use %rbp.
    subq  $16, %rsp         # Room for one local
                            # variable, keeping %rsp
                            # aligned to 16.

    movq  %rdi, %rax        # If the number is 1, that
    cmpq  $1, %rax          # is our base case, and we
    je    end_factorial     # simply return (1 is
                            # already in %rax as the
                            # return value).

    movq  %rdi, -8(%rbp)    # Save our number in a
                            # local variable: the call
                            # below may overwrite %rdi.
    decq  %rdi              # Decrease the number.
    call  factorial         # Call factorial with the
                            # number minus one.
    imulq -8(%rbp), %rax    # Multiply our number by
                            # the result of the last
                            # call to factorial (in
                            # %rax). The answer stays
                            # in %rax, which is good
                            # since that's where
                            # return values go.

end_factorial:
    movq  %rbp, %rsp        # Standard function return
    popq  %rbp              # stuff - we have to
                            # restore %rbp and %rsp to
                            # where they were before
                            # the function started.
    ret                     # Return from the function
                            # (this pops the return
                            # address, too).
