    .section .note.GNU-stack,"",@progbits

    .include "006-01-linux.s"      # Linux Definitions.

    .section .data          # This is where it will be
        tmp_buffer:         # stored: 21 bytes, enough
            .fill 21, 1, 0  # for any 64-bit number.

    .section .text
        .globl _start

_start:
    movq  $824, %rdi        # Number to convert.
    leaq  tmp_buffer(%rip), %rsi
                            # Storage for the result.
    call  integer2string

    leaq  tmp_buffer(%rip), %rdi
                            # Get the character count
    call  count_chars       # for our system call.

    movq  %rax, %rdx        # The count goes in %rdx
                            # for SYS_WRITE.
    movq  $SYS_WRITE, %rax  # Make the system call.
    movq  $STDOUT, %rdi
    leaq  tmp_buffer(%rip), %rsi
    syscall

    movq  $STDOUT, %rdi     # Write a newline.
    call  write_newline

    movq  $SYS_EXIT, %rax   # Exit.
    movq  $0, %rdi
    syscall
