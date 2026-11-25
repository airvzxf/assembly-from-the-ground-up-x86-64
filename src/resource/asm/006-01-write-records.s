    .section .note.GNU-stack,"",@progbits

    .include "006-01-linux.s"      # Linux Definitions.
    .include "006-01-record-def.s" # Record definitions

    .section .data
        # ----- CONSTANTS ----- #
        #
        # Constant data of the records we want to
        # write. Each text data item is padded to the
        # proper length with null (i.e. 0) bytes.
        #
        # `.rept` is used to pad each item.  It tells
        # the assembler to repeat the section between
        # `.rept` and `.endr` the number of times
        # specified. This is used in this program to
        # add extra null characters at the end of each
        # field to fill it up.
        #
        record1:
            .ascii "Fredrick\0"
            .rept 31            # Padding to 40 bytes.
            .byte 0
            .endr

            .ascii "Bartlett\0"
            .rept 31            # Padding to 40 bytes.
            .byte 0
            .endr

            .ascii "4242 S Prairie\nTulsa, OK 55555\0"
            .rept 209           # Padding to 240 bytes.
            .byte 0
            .endr

            .quad 45

        record2:
            .ascii "Marilyn\0"
            .rept 32            # Padding to 40 bytes.
            .byte 0
            .endr

            .ascii "Taylor\0"
            .rept 33            # Padding to 40 bytes.
            .byte 0
            .endr

            .ascii "2224 S Johannan St\n"
            .ascii "Chicago, IL 12345\0"
            .rept 203           # Padding to 240 bytes.
            .byte 0
            .endr

            .quad 29

        record3:
            .ascii "Derrick\0"
            .rept 32            # Padding to 40 bytes.
            .byte 0
            .endr

            .ascii "McIntire\0"
            .rept 31            # Padding to 40 bytes.
            .byte 0
            .endr

            .ascii "500 W Oakland\n"
            .ascii "San Diego, CA 54321\0"
            .rept 206           # Padding to 240 bytes.
            .byte 0
            .endr

            .quad 36
        records_end:

        # Check that every record is exactly
        # RECORD_SIZE bytes long. If one is not,
        # the assembler stops with this message.
        #
        .if (record2 - record1) != RECORD_SIZE
        .error "record1 is not RECORD_SIZE bytes"
        .endif
        .if (record3 - record2) != RECORD_SIZE
        .error "record2 is not RECORD_SIZE bytes"
        .endif
        .if (records_end - record3) != RECORD_SIZE
        .error "record3 is not RECORD_SIZE bytes"
        .endif

        file_name:
                            # This is the name of the
                            # file we will write to.
            .ascii "test.dat\0"

    .section .text
        .equ ST_FILE_DESCRIPTOR,  -8

        .globl _start

_start:
    movq  %rsp, %rbp        # Copy the stack pointer to
                            # %rbp.
    subq  $16, %rsp         # Allocate space to hold
                            # the file descriptor.

    movq  $SYS_OPENAT, %rax # Open the file.
    movq  $AT_FDCWD, %rdi
    leaq  file_name(%rip), %rsi
    movq  $O_CREAT_WRONLY_TRUNC, %rdx
                            # This says to create if it
                            # does not exist, empty it
                            # if it does, and open for
                            # writing.
    movq  $0666, %r10
    syscall

                            # Store the file descriptor
                            # away.
    movq  %rax, ST_FILE_DESCRIPTOR(%rbp)

                            # Write the first record.
    movq  ST_FILE_DESCRIPTOR(%rbp), %rdi
    leaq  record1(%rip), %rsi
    call  write_record

                            # Write the second record.
    movq  ST_FILE_DESCRIPTOR(%rbp), %rdi
    leaq  record2(%rip), %rsi
    call  write_record

                            # Write the third record.
    movq  ST_FILE_DESCRIPTOR(%rbp), %rdi
    leaq  record3(%rip), %rsi
    call  write_record

                            # Close the file descriptor
    movq  $SYS_CLOSE, %rax
    movq  ST_FILE_DESCRIPTOR(%rbp), %rdi
    syscall

                            # Exit the program.
    movq  $SYS_EXIT, %rax
    movq  $0, %rdi
    syscall
