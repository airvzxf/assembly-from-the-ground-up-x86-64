    // PURPOSE:
    //     The first program of Chapter 3 for AArch64:
    //     exit with the status 0.
    //
    .section .note.GNU-stack,"",@progbits

    .section .text
        .globl _start

_start:
    mov  x8, #93            // System call 93 is exit.
    mov  x0, #0             // The exit status.
    svc  #0                 // Call the kernel.
