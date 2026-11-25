    # Link with `0AK-06-01-record-io.o`.
    #
    # PURPOSE:
    #     Write two records with a phone number to
    #     `test-phone.dat`.
    #
    .section .note.GNU-stack,"",@progbits

    .include "006-01-linux.s"
    .include "0AK-06-01-record-def.s"

    .section .data
        file_name:
            .ascii "test-phone.dat\0"

        # Each field is padded with zeros up to its
        # size; `.space N` reserves N zero bytes.
        record1:
            .ascii "Fredrick\0"
            .space 40 - 9
            .ascii "Bartlett\0"
            .space 40 - 9
            .ascii "4242 S Prairie\nTulsa, OK 55555\0"
            .space 240 - 31
            .quad 45
            .ascii "555-0100\0"
            .space 24 - 9
        record2:
            .ascii "Marilyn\0"
            .space 40 - 8
            .ascii "Taylor\0"
            .space 40 - 7
            .ascii "2224 S Johannan St\nChicago, IL\0"
            .space 240 - 31
            .quad 29
            .ascii "555-0199\0"
            .space 24 - 9
        records_end:

        .if (record2 - record1) != RECORD_SIZE
        .error "record1 is not RECORD_SIZE bytes"
        .endif
        .if (records_end - record2) != RECORD_SIZE
        .error "record2 is not RECORD_SIZE bytes"
        .endif

    .section .text
        .globl _start

_start:
    movq  $SYS_OPENAT, %rax
    movq  $AT_FDCWD, %rdi
    leaq  file_name(%rip), %rsi
    movq  $O_CREAT_WRONLY_TRUNC, %rdx
    movq  $0666, %r10
    syscall
    movq  %rax, %r12         # File descriptor, in a
                             # callee-saved register.

    movq  %r12, %rdi
    leaq  record1(%rip), %rsi
    call  write_record
    movq  %r12, %rdi
    leaq  record2(%rip), %rsi
    call  write_record

    movq  $SYS_CLOSE, %rax
    movq  %r12, %rdi
    syscall
    movq  $SYS_EXIT, %rax
    movq  $0, %rdi
    syscall
