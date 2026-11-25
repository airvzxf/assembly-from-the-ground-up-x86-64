    .section .note.GNU-stack,"",@progbits

    .include "006-01-linux.s"      # Linux Definitions.
    .include "006-01-record-def.s" # Record definitions

    .section .data
        file_name:
            .ascii "test.dat\0"

        record_buffer_ptr:
            .quad 0

    .section .text
        .globl _start

_start:
    # ----- Main Program ----- #
    #
    # These are the locations on the stack where we
    # will store the input and output descriptors
    # (FYI - we could have used memory addresses in a
    # .data section instead).
    #
    .equ ST_INPUT_DESCRIPTOR,   -8
    .equ ST_OUTPUT_DESCRIPTOR,  -16

    movq  %rsp, %rbp        # Copy the stack pointer to
                            # %rbp.
    subq  $16, %rsp         # Allocate space to hold
                            # the file descriptors.

    call  allocate_init

    movq  $RECORD_SIZE, %rdi
    call  allocate
    movq  %rax, record_buffer_ptr(%rip)

    movq  $SYS_OPENAT, %rax # Open the file.
    movq  $AT_FDCWD, %rdi
    leaq  file_name(%rip), %rsi
    movq  $O_RDONLY, %rdx   # This says to open
                            # read-only.
    movq  $0666, %r10
    syscall

    # ----- Save file descriptor ----- #
    #
    movq  %rax, ST_INPUT_DESCRIPTOR(%rbp)

    # Even though it is a constant, we are saving the
    # output file descriptor in a local variable so
    # that if we later decide that it is not always
    # going to be STDOUT, we can change it easily.
    #
    movq  $STDOUT, ST_OUTPUT_DESCRIPTOR(%rbp)

record_read_loop:
    movq  ST_INPUT_DESCRIPTOR(%rbp), %rdi
    movq  record_buffer_ptr(%rip), %rsi
    call  read_record

    # Returns the number of bytes read. If it is not
    # the same number we requested, then it is either
    # an end-of-file, or an error, so we are quitting.
    #
    cmpq  $RECORD_SIZE, %rax
    jne   finished_reading

    # Otherwise, print out the first name but we must
    # know the size.
    #
    movq  record_buffer_ptr(%rip), %rdi
    addq  $RECORD_FIRSTNAME, %rdi
    call  count_chars

    movq  %rax, %rdx
    movq  ST_OUTPUT_DESCRIPTOR(%rbp), %rdi
    movq  record_buffer_ptr(%rip), %rsi
    addq  $RECORD_FIRSTNAME, %rsi
    movq  $SYS_WRITE, %rax
    syscall

    movq  ST_OUTPUT_DESCRIPTOR(%rbp), %rdi
    call  write_newline

    jmp   record_read_loop

finished_reading:
    movq  record_buffer_ptr(%rip), %rdi
    call  deallocate

    movq  $SYS_EXIT, %rax
    movq  $0, %rdi
    syscall
