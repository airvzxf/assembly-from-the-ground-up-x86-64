    # PURPOSE:
    #     Show the memory map of this program. It
    #     moves the break up by one page, asks Linux
    #     for one more page with mmap, and then copies
    #     the file /proc/self/maps, which describes
    #     the memory of the program that reads it, to
    #     STDOUT.
    #
    .section .note.GNU-stack,"",@progbits

    .include "006-01-linux.s"      # Linux Definitions.

        .equ PAGE_SIZE,      4096
        .equ BUFFER_SIZE,    4096

    .section .data
        maps_file:
            .ascii "/proc/self/maps\0"

    .section .bss
        .lcomm buffer, BUFFER_SIZE

    .section .text
        .globl _start

_start:
    movq  $SYS_BRK, %rax    # brk(0) returns the
    movq  $0, %rdi          # current break.
    syscall

    leaq  PAGE_SIZE(%rax), %rdi
    movq  $SYS_BRK, %rax    # Move the break one page
    syscall                 # up: this is the heap.

    movq  $SYS_MMAP, %rax   # mmap(0, PAGE_SIZE,
    movq  $0, %rdi          #   read and write,
    movq  $PAGE_SIZE, %rsi  #   private and anonymous,
    movq  $PROT_READ_WRITE, %rdx  # no file, 0)
    movq  $MAP_PRIVATE_ANONYMOUS, %r10
    movq  $-1, %r8
    movq  $0, %r9
    syscall                 # Linux picks the address.

    movq  $SYS_OPENAT, %rax # Open /proc/self/maps.
    movq  $AT_FDCWD, %rdi
    leaq  maps_file(%rip), %rsi
    movq  $O_RDONLY, %rdx
    syscall
    movq  %rax, %rbx        # The file descriptor.

copy_loop:
    movq  $SYS_READ, %rax
    movq  %rbx, %rdi
    leaq  buffer(%rip), %rsi
    movq  $BUFFER_SIZE, %rdx
    syscall
    cmpq  $0, %rax          # End of the file (or an
    jle   end_copy          # error)?

    movq  %rax, %rdx        # Write the bytes read.
    movq  $SYS_WRITE, %rax
    movq  $STDOUT, %rdi
    leaq  buffer(%rip), %rsi
    syscall
    jmp   copy_loop

end_copy:
    movq  $SYS_CLOSE, %rax
    movq  %rbx, %rdi
    syscall

    movq  $SYS_EXIT, %rax
    movq  $0, %rdi
    syscall
