    # Link with `006-01-read-record.o` and
    # `006-01-write-record.o`.
    #
    # PURPOSE:
    #     Solution to Chapter 6, "Going Further":
    #     add a year to every age in `test.dat`,
    #     writing each record back into the same
    #     file.
    #
    # HOW IT WORKS:
    #     The file is opened for reading and writing
    #     (O_RDWR = 2). After reading a record, the
    #     file offset points to the next record, so
    #     `lseek(fd, -RECORD_SIZE, SEEK_CUR)` moves it
    #     back to the start of the record just read
    #     before writing it again.
    #
    .section .note.GNU-stack,"",@progbits

    .include "006-01-linux.s"
    .include "006-01-record-def.s"
        .equ SEEK_CUR,   1

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
    movq  $O_RDWR, %rdx
    movq  $0666, %r10
    syscall
    movq  %rax, %r12         # File descriptor.

record_loop:
    movq  %r12, %rdi
    leaq  record_buffer(%rip), %rsi
    call  read_record
    cmpq  $RECORD_SIZE, %rax
    jne   finished
    incq  record_buffer + RECORD_AGE(%rip)

    movq  $SYS_LSEEK, %rax   # Go back one record.
    movq  %r12, %rdi
    movq  $-RECORD_SIZE, %rsi
    movq  $SEEK_CUR, %rdx
    syscall

    movq  %r12, %rdi         # Overwrite it.
    leaq  record_buffer(%rip), %rsi
    call  write_record
    jmp   record_loop

finished:
    movq  $SYS_CLOSE, %rax
    movq  %r12, %rdi
    syscall
    movq  $SYS_EXIT, %rax
    movq  $0, %rdi
    syscall
