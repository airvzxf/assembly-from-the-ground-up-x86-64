    # PURPOSE:
    #     This program converts an input file to an
    #     output file with all letters converted to
    #     uppercase.
    #
    # PROCESSING:
    #     1) Open the input file.
    #     2) Open the output file.
    #     3) While we are not at the end of the input
    #        file.
    #        a) Read part of file into our memory
    #           buffer.
    #        b) Go through each byte of memory if the
    #           byte is a lower-case letter, convert it
    #           to uppercase.
    #        c) Write the memory buffer to output file.
    #
    .section .note.GNU-stack,"",@progbits

    .section .data
        # ----- CONSTANTS ----- #
        #
        # System call numbers.
        #
        .equ SYS_READ,     0
        .equ SYS_WRITE,    1
        .equ SYS_CLOSE,    3
        .equ SYS_EXIT,     60
        .equ SYS_OPENAT,   257

        # Directory for openat: the current one.
        #
        .equ AT_FDCWD,     -100

        # Options for open:
        # Look at /usr/include/asm-generic/fcntl.h
        # for various values. You can combine them
        # by adding them or ORing them. It is
        # discussed at greater length in "Counting
        # Like a Computer".
        #
        .equ O_RDONLY,              0
        .equ O_CREAT_WRONLY_TRUNC,  01101

        # Standard file descriptors.
        #
        .equ STDIN,   0
        .equ STDOUT,  1
        .equ STDERR,  2

                            # This is the return value
                            # of read which means we
                            # have hit the end of the
                            # file.
        .equ END_OF_FILE,       0

        .equ NUMBER_ARGUMENTS,  2

    .section .bss
        # Buffer:
        #     This is where the data is loaded into
        #     from the data file and written from into
        #     the output file.
        #
        .equ   BUFFER_SIZE,     500
        .lcomm BUFFER_DATA,     BUFFER_SIZE

    .section .text
        .globl _start

        # ----- STACK POSITIONS ----- #
        #
        .equ ST_SIZE_RESERVE,   16
        .equ ST_FD_IN,         -8
        .equ ST_FD_OUT,        -16
        .equ ST_ARGC,           0  # Number of args
        .equ ST_ARGV_0,         8  # Name of program.
        .equ ST_ARGV_1,         16 # Input file name.
        .equ ST_ARGV_2,         24 # Output file name.

_start:
    # ----- INITIALIZE PROGRAM ----- #
    #
    movq  %rsp, %rbp        # Save the stack pointer.
                            # Allocate space for our
                            # file descriptors on the
                            # stack.
    subq  $ST_SIZE_RESERVE, %rsp

open_files:

open_fd_in:
    # ----- OPEN INPUT FILE ----- #
    #
    movq  $SYS_OPENAT, %rax # Open syscall.
    movq  $AT_FDCWD, %rdi   # Relative to the
                            # current directory.
    movq  ST_ARGV_1(%rbp), %rsi     # Input filename
                                    # into %rsi.
    movq  $O_RDONLY, %rdx   # Read-only flag.
    movq  $0666, %r10       # This does not matter for
                            # reading.
    syscall                 # Call Linux.

store_fd_in:
    # ----- STORE INPUT FILE DESCRIPTOR ----- #
    #
    movq  %rax, ST_FD_IN(%rbp)      # Save the given
                                    # file descriptor.

open_fd_out:
    # ----- OPEN OUTPUT FILE ----- #
    #
    movq  $SYS_OPENAT, %rax # Open the file.
    movq  $AT_FDCWD, %rdi
                            # Output filename into %rsi
    movq  ST_ARGV_2(%rbp), %rsi
                            # Flags for writing to the
                            # file.
    movq  $O_CREAT_WRONLY_TRUNC, %rdx
    movq  $0666, %r10       # Permission set for new
                            # file (if it is created).
    syscall                 # Call Linux.

store_fd_out:
    # ----- STORE OUTPUT FILE DESCRIPTOR ----- #
    #
                            # Store the file descriptor
                            # here.
    movq  %rax, ST_FD_OUT(%rbp)

    # ----- BEGIN MAIN LOOP ----- #
    #
read_loop_begin:
    # ----- READ IN A BLOCK FROM THE INPUT FILE ----- #
    #
    movq  $SYS_READ, %rax
                            # Get the input file
                            # descriptor.
    movq  ST_FD_IN(%rbp), %rdi
                            # The location to read into
    leaq  BUFFER_DATA(%rip), %rsi
                            # The size of the buffer.
    movq  $BUFFER_SIZE, %rdx
    syscall                 # Size of buffer read is
                            # returned in %rax.

    # ----- EXIT IF WE HAVE REACHED THE END ----- #
    #
                            # Check for end of file
                            # marker.
    cmpq  $END_OF_FILE, %rax
    jle   end_loop          # If found or on error, go
                            # to the end.

continue_read_loop:
    # ----- CONVERT THE BLOCK TO UPPER CASE ----- #
    #
    movq  %rax, %rbx        # Keep the size in %rbx:
                            # the function must not
                            # change it.
    leaq  BUFFER_DATA(%rip), %rdi  # Location of the
                                   # buffer.
    movq  %rbx, %rsi        # Size of the buffer.
    call  convert_to_upper

    # --- WRITE THE BLOCK OUT TO THE OUTPUT FILE --- #
    #
    movq  $SYS_WRITE, %rax
                            # File to use.
    movq  ST_FD_OUT(%rbp), %rdi
                            # Location of the buffer.
    leaq  BUFFER_DATA(%rip), %rsi
    movq  %rbx, %rdx        # Size of the buffer.
    syscall

    # ----- CONTINUE THE LOOP ----- #
    #
    jmp   read_loop_begin

end_loop:
    # ----- CLOSE THE FILES ----- #
    # NOTE:
    #     We do not need to do error checking on
    #     these, because error conditions do not
    #     signify anything special here.
    #
    movq  $SYS_CLOSE, %rax
    movq  ST_FD_OUT(%rbp), %rdi
    syscall

    movq  $SYS_CLOSE, %rax
    movq  ST_FD_IN(%rbp), %rdi
    syscall

    # ----- EXIT ----- #
    #
    movq  $SYS_EXIT, %rax
    movq  $0, %rdi
    syscall


    # PURPOSE:
    #     This function actually does the
    #     conversion to upper case for a block.
    #
    # INPUT:
    #     %rdi - The starting address of the block
    #            of memory to convert.
    #     %rsi - The length of that block.
    #
    # OUTPUT:
    #     This function overwrites the current
    #     buffer with the upper-casified version.
    #
    # VARIABLES:
    #     %rdi - beginning of buffer.
    #     %rsi - length of buffer.
    #     %rcx - current buffer offset.
    #     %al  - current byte being examined (lowest
    #            byte of %rax).
    #
    # ----- CONSTANTS ----- #
    #
                            # The lower boundary of our
                            # search.
        .equ  LOWERCASE_A,       'a'
                            # The upper boundary of our
                            # search.
        .equ  LOWERCASE_Z,       'z'
                            # Conversion between upper
                            # lower case.
        .equ  UPPER_CONVERSION,  'A' - 'a'

    .type convert_to_upper, @function
convert_to_upper:
    pushq %rbp
    movq  %rsp, %rbp

    # ----- SET UP VARIABLES ----- #
    #
    movq  $0, %rcx

    cmpq  $0, %rsi          # If a buffer with zero
                            # length was given to us,
                            # just leave.
    je    end_convert_loop

convert_loop:
                            # Get the current byte.
    movb  (%rdi,%rcx,1), %al

                            # Go to the next byte
                            # unless it is between 'a'
                            # and 'z'.
    cmpb  $LOWERCASE_A, %al
    jl    next_byte
    cmpb  $LOWERCASE_Z, %al
    jg    next_byte

                            # Otherwise convert the
                            # byte to uppercase and
                            # store it back.
    addb  $UPPER_CONVERSION, %al
    movb  %al, (%rdi,%rcx,1)

next_byte:
    incq  %rcx              # Next byte.
    cmpq  %rcx, %rsi        # Continue unless we have
                            # reached the end.
    jne   convert_loop

end_convert_loop:
    movq  %rbp, %rsp        # No return value, just
    popq  %rbp              # leave.
    ret
