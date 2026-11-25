    .section .note.GNU-stack,"",@progbits

    .include "006-01-linux.s"      # Linux Definitions.
    .include "006-01-record-def.s" # Record definitions

    # PURPOSE:
    #     This function reads a record from the file
    #     descriptor.
    #
    # INPUT:
    #     %rdi - The file descriptor.
    #     %rsi - The address of a buffer of
    #            RECORD_SIZE bytes.
    #
    # OUTPUT:
    #     This function writes the data to the buffer
    #     and returns the result of `read` in %rax.
    #
    .section .text
        .globl read_record
        .type  read_record,  @function

read_record:
    pushq %rbp
    movq  %rsp, %rbp

                        # The file descriptor and the
                        # buffer are already in %rdi
                        # and %rsi, where `read` wants
                        # them.
    movq  $RECORD_SIZE, %rdx
    movq  $SYS_READ, %rax
    syscall             # NOTE - %rax has the return
                        # value, which we will give
                        # back to our calling program.

    movq  %rbp, %rsp
    popq  %rbp
    ret
