    # PURPOSE:
    #     `read_record` and `write_record` for the
    #     record with a phone number. The code is the
    #     same as in `006-01-read-record.s` and
    #     `006-01-write-record.s`; only RECORD_SIZE
    #     changes, so they must be reassembled.
    #
    # INPUT (both functions):
    #     %rdi - File descriptor.
    #     %rsi - Address of the buffer.
    #
    # OUTPUT:
    #     %rax - Result of the read/write call.
    #
    .section .note.GNU-stack,"",@progbits

    .include "006-01-linux.s"
    .include "0AK-06-01-record-def.s"

    .section .text
        .globl read_record
        .type  read_record, @function
read_record:
    pushq %rbp
    movq  %rsp, %rbp
    movq  $RECORD_SIZE, %rdx
    movq  $SYS_READ, %rax
    syscall
    movq  %rbp, %rsp
    popq  %rbp
    ret

        .globl write_record
        .type  write_record, @function
write_record:
    pushq %rbp
    movq  %rsp, %rbp
    movq  $RECORD_SIZE, %rdx
    movq  $SYS_WRITE, %rax
    syscall
    movq  %rbp, %rsp
    popq  %rbp
    ret
