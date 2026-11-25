    # Link with `006-01-read-record.o`,
    # `006-01-write-record.o`, `007-01-error-exit.o`,
    # `006-01-count-chars.o` and
    # `006-01-write-newline.o`.
    #
    # PURPOSE:
    #     Solution to Chapter 7, "Use the Concepts":
    #     `007-01-add-year` with error checking after
    #     every system call, and a recovery point: if
    #     `test.dat` can't be opened, the records are
    #     read from STDIN instead.
    #
    # USAGE:
    #     ./0AK-07-01-add-year-robust
    #     ./0AK-07-01-add-year-robust < other.dat
    #
    # NOTES:
    #     System calls return a negative number
    #     (-errno) on failure. A read that returns
    #     more than 0 but less than a whole record
    #     means the file is damaged.
    #
    .section .note.GNU-stack,"",@progbits

    .include "006-01-linux.s"
    .include "006-01-record-def.s"

    .section .data
        input_file_name:
            .ascii "test.dat\0"
        output_file_name:
            .ascii "testout.dat\0"
        msg_recover:
            .ascii "Warning: can't open test.dat, "
            .ascii "reading STDIN\n"
        msg_recover_end:
        .equ RECOVER_LEN, msg_recover_end - msg_recover
        code_output:
            .ascii "0002: \0"
        msg_output:
            .ascii "Can't Open Output File.\0"
        code_read:
            .ascii "0003: \0"
        msg_read:
            .ascii "Can't Read Input File.\0"
        code_partial:
            .ascii "0004: \0"
        msg_partial:
            .ascii "Incomplete Record.\0"
        code_write:
            .ascii "0005: \0"
        msg_write:
            .ascii "Can't Write Output File.\0"
        code_close:
            .ascii "0006: \0"
        msg_close:
            .ascii "Can't Close Output File.\0"

    .section .bss
        .lcomm record_buffer, RECORD_SIZE

    .section .text
        .globl _start
        # %r12 - Input file descriptor.
        # %r13 - Output file descriptor.

_start:
    movq  $SYS_OPENAT, %rax
    movq  $AT_FDCWD, %rdi
    leaq  input_file_name(%rip), %rsi
    movq  $O_RDONLY, %rdx
    movq  $0666, %r10
    syscall
    movq  %rax, %r12
    cmpq  $0, %rax
    jge   open_output

    # Recovery point: use STDIN instead.
    movq  $STDIN, %r12
    movq  $SYS_WRITE, %rax
    movq  $STDERR, %rdi
    leaq  msg_recover(%rip), %rsi
    movq  $RECOVER_LEN, %rdx
    syscall                  # Nothing useful to do
                             # if this one fails.

open_output:
    movq  $SYS_OPENAT, %rax
    movq  $AT_FDCWD, %rdi
    leaq  output_file_name(%rip), %rsi
    movq  $O_CREAT_WRONLY_TRUNC, %rdx
    movq  $0666, %r10
    syscall
    movq  %rax, %r13
    cmpq  $0, %rax
    jl    error_output

loop_begin:
    movq  %r12, %rdi
    leaq  record_buffer(%rip), %rsi
    call  read_record
    cmpq  $0, %rax
    jl    error_read         # Read failed.
    je    loop_end           # End of file.
    cmpq  $RECORD_SIZE, %rax
    jne   error_partial      # Damaged file.

    incq  record_buffer + RECORD_AGE(%rip)

    movq  %r13, %rdi
    leaq  record_buffer(%rip), %rsi
    call  write_record
    cmpq  $RECORD_SIZE, %rax # Everything written?
    jne   error_write
    jmp   loop_begin

loop_end:
    movq  $SYS_CLOSE, %rax   # Closing the output
    movq  %r13, %rdi         # can report a delayed
    syscall                  # write error.
    cmpq  $0, %rax
    jl    error_close
    movq  $SYS_EXIT, %rax
    movq  $0, %rdi
    syscall

error_output:
    leaq  code_output(%rip), %rdi
    leaq  msg_output(%rip), %rsi
    call  error_exit
error_read:
    leaq  code_read(%rip), %rdi
    leaq  msg_read(%rip), %rsi
    call  error_exit
error_partial:
    leaq  code_partial(%rip), %rdi
    leaq  msg_partial(%rip), %rsi
    call  error_exit
error_write:
    leaq  code_write(%rip), %rdi
    leaq  msg_write(%rip), %rsi
    call  error_exit
error_close:
    leaq  code_close(%rip), %rdi
    leaq  msg_close(%rip), %rsi
    call  error_exit
