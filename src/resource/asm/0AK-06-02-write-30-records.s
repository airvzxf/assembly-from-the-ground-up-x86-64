    # Link with `006-01-write-record.o`.
    #
    # PURPOSE:
    #     Solution to Chapter 6, "Use the Concepts":
    #     write 30 identical records to `test30.dat`
    #     with a loop.
    #
    # OUTPUT:
    #     A file of 30 * 328 = 9840 bytes.
    #
    .section .note.GNU-stack,"",@progbits

    .include "006-01-linux.s"
    .include "006-01-record-def.s"

    .section .data
        file_name:
            .ascii "test30.dat\0"
        record:
            .ascii "Fredrick\0"
            .space 40 - 9
            .ascii "Bartlett\0"
            .space 40 - 9
            .ascii "4242 S Prairie\nTulsa, OK 55555\0"
            .space 240 - 31
            .quad 45

    .section .text
        .globl _start
        .equ RECORD_COUNT, 30

_start:
    movq  $SYS_OPENAT, %rax
    movq  $AT_FDCWD, %rdi
    leaq  file_name(%rip), %rsi
    movq  $O_CREAT_WRONLY_TRUNC, %rdx
    movq  $0666, %r10
    syscall
    movq  %rax, %r12         # File descriptor.
    movq  $RECORD_COUNT, %r13    # Loop counter.

write_loop:
    movq  %r12, %rdi
    leaq  record(%rip), %rsi
    call  write_record
    decq  %r13
    jnz   write_loop         # Until %r13 = 0.

    movq  $SYS_CLOSE, %rax
    movq  %r12, %rdi
    syscall
    movq  $SYS_EXIT, %rax
    movq  $0, %rdi
    syscall
