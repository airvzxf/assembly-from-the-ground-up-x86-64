    .section .note.GNU-stack,"",@progbits

    .include "006-01-linux.s"      # Linux Definitions.
    .include "006-01-record-def.s" # Record definitions

    .section .data
        input_file_name:
            .ascii "test.dat\0"

        output_file_name:
            .ascii "testout.dat\0"

    .section .bss
        .lcomm record_buffer,  RECORD_SIZE

        # --- Stack offsets of local variables --- #
        #
        .equ ST_INPUT_DESCRIPTOR,  -8
        .equ ST_OUTPUT_DESCRIPTOR, -16

    .section .text
        .globl _start

_start:
    movq  %rsp, %rbp        # Copy stack pointer and
    subq  $16, %rsp         # make room for local
                            # variables.

    movq  $SYS_OPENAT, %rax # Open file for reading.
    movq  $AT_FDCWD, %rdi
    leaq  input_file_name(%rip), %rsi
    movq  $O_RDONLY, %rdx
    movq  $0666, %r10
    syscall

    movq  %rax, ST_INPUT_DESCRIPTOR(%rbp)

                    # This will test and see if %rax is
                    # negative.  If it is not negative,
                    # it will jump to
                    # continue_processing. Otherwise
                    # it will handle the error
                    # condition that the negative
                    # number represents.
                    #
    cmpq  $0, %rax
    jge   continue_processing

    # ----- SEND THE ERROR ----- #
    #
    .section .data
        no_open_file_code:
            .ascii "0001: \0"
        no_open_file_msg:
            .ascii "Can't Open Input File.\0"

    .section .text
    leaq  no_open_file_code(%rip), %rdi
    leaq  no_open_file_msg(%rip), %rsi
    call  error_exit

continue_processing:

    movq  $SYS_OPENAT, %rax # Open file for writing.
    movq  $AT_FDCWD, %rdi
    leaq  output_file_name(%rip), %rsi
    movq  $O_CREAT_WRONLY_TRUNC, %rdx
    movq  $0666, %r10
    syscall

    movq  %rax, ST_OUTPUT_DESCRIPTOR(%rbp)

loop_begin:
    movq  ST_INPUT_DESCRIPTOR(%rbp), %rdi
    leaq  record_buffer(%rip), %rsi
    call  read_record

    # Returns the number of bytes read. If it is not
    # the same number we requested, then it is either
    # an end-of-file, or an error, so we are quitting.
    #
    cmpq  $RECORD_SIZE, %rax
    jne   loop_end

                            # Increment the age.
    incq  record_buffer + RECORD_AGE(%rip)

                            # Write the record out.
    movq  ST_OUTPUT_DESCRIPTOR(%rbp), %rdi
    leaq  record_buffer(%rip), %rsi
    call  write_record

    jmp   loop_begin

loop_end:
    movq  $SYS_EXIT, %rax
    movq  $0, %rdi
    syscall
