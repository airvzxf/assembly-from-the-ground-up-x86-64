    // PURPOSE:
    //     003-02-maximum for AArch64: find the
    //     largest number of a list that ends with 0,
    //     and return it as the exit status.
    //
    // REGISTERS:
    //     x1 - the address of data_items
    //     x2 - the index of the current item
    //     x3 - the current item
    //     x0 - the largest item so far
    //
    .section .note.GNU-stack,"",@progbits

    .section .data
        data_items:
            .quad 3, 67, 34, 222, 45, 22, 11, 125, 0

    .section .text
        .globl _start

_start:
    adrp x1, data_items     // The 4096-byte page of
                            // data_items, relative
                            // to this instruction,
    add  x1, x1, :lo12:data_items  // plus its offset
                            // inside the page.
    mov  x2, #0             // The index starts at 0.
    ldr  x0, [x1]           // The first item is the
                            // largest so far.
loop:
    ldr  x3, [x1, x2, lsl #3]  // x3 = item at x1 +
                            // x2 * 8.
    cbz  x3, done           // A 0 ends the list.
    cmp  x3, x0             // Compare with the
    csel x0, x3, x0, gt     // largest; keep the
                            // bigger one.
    add  x2, x2, #1         // The next item.
    b    loop

done:
    mov  x8, #93            // exit, with the largest
    svc  #0                 // item in x0.
