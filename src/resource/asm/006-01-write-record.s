    .section .note.GNU-stack,"",@progbits

    .include "006-01-linux.s"      # Linux Definitions.
    .include "006-01-record-def.s" # Record definitions

    # PURPOSE:
    #     This function writes a record to the given
    #     file descriptor.
    #
    # INPUT:
    #     %rdi - The file descriptor.
    #     %rsi - The address of the record.
    #
    # OUTPUT:
    #     This function returns the result of `write`
    #     in %rax.
    #
    .section .text
        .globl write_record
        .type  write_record,  @function

write_record:
    pushq %rbp
    movq  %rsp, %rbp

                        # The file descriptor and the
                        # buffer are already in %rdi
                        # and %rsi, where `write` wants
                        # them.
    movq  $RECORD_SIZE, %rdx
    movq  $SYS_WRITE, %rax
    syscall             # NOTE - %rax has the return
                        # value, which we will give
                        # back to our calling program.

    movq  %rbp, %rsp
    popq  %rbp
    ret
