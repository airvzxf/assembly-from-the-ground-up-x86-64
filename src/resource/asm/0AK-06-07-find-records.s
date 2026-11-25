    # Link with `0AK-06-06-compare-strings.o`,
    # `006-01-read-record.o`, `006-01-count-chars.o`
    # and `006-01-write-newline.o`.
    #
    # PURPOSE:
    #     Solution to Chapter 6, "Going Further":
    #     read up to 5 characters from STDIN and
    #     print the first name of every record in
    #     `test.dat` that starts with them.
    #
    # USAGE:
    #     echo Mar | ./0AK-06-07-find-records
    #
    .section .note.GNU-stack,"",@progbits

    .include "006-01-linux.s"
    .include "006-01-record-def.s"
        .equ INPUT_SIZE, 5

    .section .data
        file_name:
            .ascii "test.dat\0"

    .section .bss
        .lcomm record_buffer, RECORD_SIZE
        .lcomm input, INPUT_SIZE + 1  # + null byte.

    .section .text
        .globl _start

_start:
    movq  $SYS_READ, %rax    # Read the prefix.
    movq  $STDIN, %rdi
    leaq  input(%rip), %rsi
    movq  $INPUT_SIZE, %rdx
    syscall
    cmpq  $0, %rax           # Nothing read (or an
    jle   exit               # error): stop.

    # End the text at the first newline, if any,
    # so "Mar\n" is used as "Mar".
    leaq  input(%rip), %rdx
    movq  $0, %rcx
find_newline:
    cmpq  %rax, %rcx
    je    open_file
    cmpb  $'\n', (%rdx,%rcx,1)
    je    cut
    incq  %rcx
    jmp   find_newline
cut:
    movb  $0, (%rdx,%rcx,1)

open_file:
    movq  $SYS_OPENAT, %rax
    movq  $AT_FDCWD, %rdi
    leaq  file_name(%rip), %rsi
    movq  $O_RDONLY, %rdx
    movq  $0666, %r10
    syscall
    movq  %rax, %r12         # File descriptor.

record_loop:
    movq  %r12, %rdi
    leaq  record_buffer(%rip), %rsi
    call  read_record
    cmpq  $RECORD_SIZE, %rax
    jne   exit

    leaq  input(%rip), %rdi
    leaq  record_buffer + RECORD_FIRSTNAME(%rip), %rsi
    call  compare_strings
    cmpq  $1, %rax
    jne   record_loop        # No match.

    leaq  record_buffer + RECORD_FIRSTNAME(%rip), %rdi
    call  count_chars
    movq  %rax, %rdx
    movq  $SYS_WRITE, %rax
    movq  $STDOUT, %rdi
    leaq  record_buffer + RECORD_FIRSTNAME(%rip), %rsi
    syscall
    movq  $STDOUT, %rdi
    call  write_newline
    jmp   record_loop

exit:
    movq  $SYS_EXIT, %rax
    movq  $0, %rdi
    syscall
