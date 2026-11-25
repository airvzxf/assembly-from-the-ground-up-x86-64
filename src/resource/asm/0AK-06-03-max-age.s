    # Link with `006-01-read-record.o`.
    #
    # PURPOSE:
    #     Solution to Chapter 6, "Use the Concepts":
    #     find the largest age in `test.dat` and
    #     return it as the exit status code.
    #     Create `test.dat` first with
    #     `006-01-write-records`.
    #
    # VARIABLES:
    #     %r12 - File descriptor.
    #     %r13 - largest age so far.
    #     %r14 - 1 until the first record is read.
    #
    .section .note.GNU-stack,"",@progbits

    .include "006-01-linux.s"
    .include "006-01-record-def.s"

    .section .data
        file_name:
            .ascii "test.dat\0"

    .section .bss
        .lcomm record_buffer, RECORD_SIZE

    .section .text
        .globl _start

_start:
    movq  $SYS_OPENAT, %rax
    movq  $AT_FDCWD, %rdi
    leaq  file_name(%rip), %rsi
    movq  $O_RDONLY, %rdx
    movq  $0666, %r10
    syscall
    movq  %rax, %r12
    movq  $0, %r13           # 0 if there are no
    movq  $1, %r14           # records.

record_loop:
    movq  %r12, %rdi
    leaq  record_buffer(%rip), %rsi
    call  read_record
    cmpq  $RECORD_SIZE, %rax
    jne   finished
    movq  record_buffer + RECORD_AGE(%rip), %rax
    cmpq  $1, %r14           # First record: it is
    je    new_value          # the largest so far.
    cmpq  %r13, %rax
    jle   record_loop       # Not larger.
new_value:
    movq  %rax, %r13
    movq  $0, %r14
    jmp   record_loop

finished:
    movq  $SYS_CLOSE, %rax
    movq  %r12, %rdi
    syscall
    movq  $SYS_EXIT, %rax
    movq  %r13, %rdi         # The age is the
    syscall                  # status code.
