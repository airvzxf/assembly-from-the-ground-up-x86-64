    # Link with `0AK-06-01-record-io.o`,
    # `006-01-count-chars.o` and
    # `006-01-write-newline.o`.
    #
    # PURPOSE:
    #     Print the first name and the phone number
    #     of every record in `test-phone.dat`.
    #
    .section .note.GNU-stack,"",@progbits

    .include "006-01-linux.s"
    .include "0AK-06-01-record-def.s"

    .section .data
        file_name:
            .ascii "test-phone.dat\0"
        separator:
            .ascii ": "

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
    movq  %rax, %r12         # File descriptor.

record_loop:
    movq  %r12, %rdi
    leaq  record_buffer(%rip), %rsi
    call  read_record
    cmpq  $RECORD_SIZE, %rax # A whole record?
    jne   finished

    leaq  record_buffer + RECORD_FIRSTNAME(%rip), %rdi
    call  print_string

    movq  $SYS_WRITE, %rax   # ": "
    movq  $STDOUT, %rdi
    leaq  separator(%rip), %rsi
    movq  $2, %rdx
    syscall

    leaq  record_buffer + RECORD_PHONE(%rip), %rdi
    call  print_string

    movq  $STDOUT, %rdi
    call  write_newline
    jmp   record_loop

finished:
    movq  $SYS_EXIT, %rax
    movq  $0, %rdi
    syscall

    # PURPOSE:
    #     Write a null-terminated string to STDOUT.
    #
    # INPUT:
    #     %rdi - Address of the string.
    #
    .type print_string, @function
print_string:
    pushq %rbp
    movq  %rsp, %rbp
    pushq %rbx               # Callee-saved: keep the
    subq  $8, %rsp           # caller's value. (The
                             # subq keeps %rsp
                             # aligned to 16.)
    movq  %rdi, %rbx         # Address of the string.
    call  count_chars
    movq  %rax, %rdx         # Length.
    movq  %rbx, %rsi
    movq  $SYS_WRITE, %rax
    movq  $STDOUT, %rdi
    syscall
    movq  -8(%rbp), %rbx     # Restore %rbx.
    movq  %rbp, %rsp
    popq  %rbp
    ret
