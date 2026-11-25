    # PURPOSE:
    #     Convert an integer number to a decimal string
    #     for display.
    #
    # INPUT:
    #     %rdi - The number to convert (unsigned).
    #     %rsi - A buffer large enough to hold the
    #            largest possible number: 20 digits
    #            and a null byte, 21 bytes.
    #
    # OUTPUT:
    #     The buffer will be overwritten with the
    #     decimal string.
    #
    # Variables:
    #     %rcx will hold the count of characters
    #     processed.
    #     %rax will hold the current value.
    #     %r8 will hold the base (10).
    #
    .section .note.GNU-stack,"",@progbits

    .section .text
        .globl integer2string
        .type  integer2string,  @function

integer2string:
    pushq %rbp              # Normal function beginning
    movq  %rsp, %rbp

    movq  $0, %rcx          # Current character count.

    movq  %rdi, %rax        # Move the value into
                            # position.

    movq  $10, %r8          # When we divide by 10, the
                            # 10 must be in a register
                            # or memory location.

conversion_loop:
    # Division is actually performed on the combined
    # %rdx:%rax register, so first clear out %rdx.
    #
    movq  $0, %rdx

    # Divide %rdx:%rax (which are implied) by 10.
    # Store the quotient in %rax and the remainder in
    # %rdx (both of which are implied).
    #
    divq  %r8

    # Quotient is in the right place. %rdx has the
    # remainder, which now needs to be converted into a
    # number. So, %rdx has a number that is 0 through
    # 9. You could also interpret this as an index on
    # the ASCII table starting from the character '0'.
    # The ascii code for '0' plus zero is still the
    # ascii code for '0'. The ascii code for '0' plus
    # 1 is the ascii code for the character '1'.
    # Therefore, the following instruction will give us
    # the character for the number stored in %rdx.
    #
    addq  $'0', %rdx

    # Now we will take this value and push it on the
    # stack. This way, when we are done, we can just
    # pop off the characters one-by-one and they will
    # be in the right order. Note that we are pushing
    # the whole register, but we only need the byte in
    # %dl (the last byte of the %rdx register) for the
    # character.
    #
    pushq %rdx

    incq  %rcx              # Increment the digit count

    cmpq  $0, %rax          # Check to see if %rax is
                            # zero yet,
    je    end_conversion_loop  # go to next step if so

                            # %rax already has its new
                            # value.

    jmp   conversion_loop

end_conversion_loop:
    # The string is now on the stack, if we pop it off
    # a character at a time we can copy it into the
    # buffer and be done. The buffer is in %rsi.
    #

copy_reversing_loop:
    # We pushed a whole register, but we only need the
    # last byte. So we are going to pop off to the
    # entire %rax register, but then only move the
    # small part (%al) into the character string.
    #
    popq  %rax
    movb  %al, (%rsi)

    decq  %rcx              # Decreasing %rcx so we
                            # know when we are finished

    incq  %rsi              # Increasing %rsi so that
                            # it will be pointing to
                            # the next byte.

    cmpq  $0, %rcx          # Check to see if we are
                            # finished.
    je    end_copy_reversing_loop  # If so, jump to
                                   # the end of the
                                   # function.

    jmp   copy_reversing_loop      # Otherwise, repeat
                                   # the loop.

end_copy_reversing_loop:
    movb  $0, (%rsi)        # Done copying. Now write
                            # a null byte and return.

    movq  %rbp, %rsp
    popq  %rbp
    ret
