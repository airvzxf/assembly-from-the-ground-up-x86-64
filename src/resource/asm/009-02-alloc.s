    # PURPOSE:
    #     Program to manage memory usage - allocates
    #     and deallocates memory as requested.
    #
    # NOTES:
    #     The programs using these routines will ask
    #     for a certain size of memory. We actually
    #     use more than that size, but we put it at
    #     the beginning, before the pointer we hand
    #     back. We add a size field and an
    #     AVAILABLE/UNAVAILABLE marker. So, the memory
    #     looks like this:
    #
    # #########################################
    # #Available Marker#Size of memory#Actual memory#
    # #########################################
    #                                  ^--Returned
    #                                     pointer
    #                                     points
    #                                     here.
    #
    #     The pointer we return only points to the
    #     actual locations requested to make it
    #     easier for the calling program. It also
    #     allows us to change our structure without
    #     the calling program having to change at
    #     all. Every size is rounded up to a multiple
    #     of 16, so every pointer we return is a
    #     multiple of 16, like the ones of the C
    #     library's malloc.
    #
    .section .note.GNU-stack,"",@progbits

    .include "006-01-linux.s"      # Linux Definitions.

    .section .data
        # ----- GLOBAL VARIABLES ----- #
        #
        heap_begin:         # This points to the
            .quad 0         # beginning of the memory
                            # we are managing.

        current_break:      # This points to one
            .quad 0         # location past the memory
                            # we are managing.

        # ----- STRUCTURE INFORMATION ----- #
        #
        .equ HEADER_SIZE,      16   # Size of space for
                                    # memory region
                                    # header.
        .equ HDR_AVAIL_OFFSET, 0    # Location of the
                                    # "available" flag
                                    # in the header.
        .equ HDR_SIZE_OFFSET,  8    # Location of the
                                    # size field in the
                                    # header.

        # ----- CONSTANTS ----- #
        #
        .equ UNAVAILABLE,    0      # This is the
                                    # number we will
                                    # use to mark space
                                    # that has been
                                    # given out.
        .equ AVAILABLE,      1      # This is the
                                    # number we will
                                    # use to mark space
                                    # that has been
                                    # returned, and is
                                    # available for
                                    # giving.

    .section .text
    # ----- FUNCTIONS ----- #
    #
    # allocate_init
    #
    # PURPOSE:
    #     Call this function to initialize the
    #     functions (specifically, this sets
    #     heap_begin and current_break). This has no
    #     parameters and no return value.
    #
        .globl allocate_init
        .type  allocate_init,  @function

allocate_init:
    pushq %rbp              # Standard function stuff.
    movq  %rsp, %rbp

    movq  $SYS_BRK, %rax    # If the brk system call is
    movq  $0, %rdi          # called with 0, it returns
    syscall                 # the current break: the
                            # first address after the
                            # memory of the program.

    addq  $15, %rax         # Round it up to a multiple
    andq  $-16, %rax        # of 16.

    movq  %rax, current_break(%rip)
                            # Store the current break.
    movq  %rax, heap_begin(%rip)
                            # Store the current break
                            # as our first address.
                            # This will cause the
                            # allocate function to get
                            # more memory from Linux
                            # the first time it is run.

    movq  %rbp, %rsp        # Exit the function.
    popq  %rbp
    ret
    # ----- END OF FUNCTION ----- #

    # allocate
    #
    # PURPOSE:
    #     This function is used to grab a section of
    #     memory. It checks to see if there are any
    #     free blocks, and, if not, it asks Linux for
    #     a new one.
    #
    # INPUT:
    #     %rdi - The size of the memory block we want
    #            to allocate.
    #
    # OUTPUT:
    #     This function returns the address of the
    #     allocated memory in %rax. If there is no
    #     memory available, it will return 0 in %rax.
    #
    # PROCESS:
    #     Variables used:
    #       %rdx - Size of the requested memory,
    #              rounded up to a multiple of 16.
    #       %rax - Current memory region being
    #              examined.
    #       %rsi - Current break position.
    #       %r8  - Size of current memory region.
    #
    #     We scan through each memory region starting
    #     with heap_begin. We look at the size of each
    #     one, and if it has been allocated. If it's
    #     big enough for the requested size, and its
    #     available, it grabs that one. If it does
    #     not find a region large enough, it asks
    #     Linux for more memory. In that case, it
    #     moves current_break up.
    #
        .globl allocate
        .type  allocate,   @function

allocate:
    pushq %rbp              # Standard function stuff.
    movq  %rsp, %rbp

    leaq  15(%rdi), %rdx    # %rdx will hold the size
    andq  $-16, %rdx        # we are looking for,
                            # rounded up to a multiple
                            # of 16.

    movq  heap_begin(%rip), %rax
                            # %rax will hold the
                            # current search location.

    movq  current_break(%rip), %rsi
                            # %rsi will hold the
                            # current break.

alloc_loop_begin:           # Here we iterate through
                            # each memory region.

    cmpq  %rsi, %rax        # Need more memory if these
    je    move_break        # are equal.

    movq  HDR_SIZE_OFFSET(%rax), %r8
                            # Grab the size of this
                            # memory.

    cmpq  $UNAVAILABLE, HDR_AVAIL_OFFSET(%rax)
                            # If the space is
    je    next_location     # unavailable, go to the
                            # next one.

    cmpq  %r8, %rdx         # If the space is
    jbe   allocate_here     # available, compare the
                            # size to the needed size.
                            # If its big enough, go to
                            # allocate_here.

next_location:
    addq  $HEADER_SIZE, %rax
    addq  %r8, %rax         # The total size of the
                            # memory region is the sum
                            # of the size requested
                            # (currently stored in
                            # %r8), plus another 16
                            # bytes for the header (8
                            # for the AVAILABLE/
                            # UNAVAILABLE flag, and 8
                            # for the size of the
                            # region). So, adding %r8
                            # and 16 to %rax will get
                            # the address of the next
                            # memory region.

    jmp   alloc_loop_begin  # Go look at the next
                            # location.

allocate_here:      # If we have made it here, that
                    # means that the region header of
                    # the region to allocate is in
                    # %rax.

                            # Mark space as
                            # unavailable.
    movq  $UNAVAILABLE, HDR_AVAIL_OFFSET(%rax)
    addq  $HEADER_SIZE, %rax
                            # Move %rax past the header
                            # to the usable memory
                            # (since that's what we
                            # return).

    movq  %rbp, %rsp        # Return from the function.
    popq  %rbp
    ret

move_break:         # If we have made it here, that
                    # means that we have exhausted all
                    # addressable memory, and we need
                    # to ask for more. %rsi holds the
                    # current endpoint of the data,
                    # and %rdx holds its size.

    movq  %rax, %r9         # The new region starts at
                            # the current break. The
                            # system call overwrites
                            # %rax, %rcx and %r11, so
                            # keep it in %r9.

    leaq  HEADER_SIZE(%rsi,%rdx), %rdi
                            # We need to increase %rsi
                            # to where we _want_ memory
                            # to end, so we add space
                            # for the header structure
                            # and space to the break
                            # for the data requested.

    movq  $SYS_BRK, %rax    # Now its time to ask Linux
    syscall                 # for more memory.

                            # Under normal conditions,
                            # this should return the
                            # new break in %rax, which
                            # is exactly what we asked
                            # for. On error, it returns
                            # the old break.
    cmpq  %rdi, %rax        # Check for error
    jne   error             # conditions.

                            # Set this memory as
                            # unavailable, since we're
                            # about to give it away.
    movq  $UNAVAILABLE, HDR_AVAIL_OFFSET(%r9)
                            # Set the size of the
                            # memory.
    movq  %rdx, HDR_SIZE_OFFSET(%r9)

    movq  %rdi, current_break(%rip)
                            # Save the new break.

    leaq  HEADER_SIZE(%r9), %rax
                            # Return the address after
                            # the header: the actual
                            # start of usable memory.

    movq  %rbp, %rsp        # Return the function.
    popq  %rbp
    ret

error:
    movq  $0, %rax          # On error, we return zero.
    movq  %rbp, %rsp
    popq  %rbp
    ret
    # ----- END OF FUNCTION ----- #

    # deallocate
    #
    # PURPOSE:
    #     The purpose of this function is to give back
    #     a region of memory to the pool after we're
    #     done using it.
    #
    # INPUT:
    #     %rdi - The address of the memory we want to
    #            return to the memory pool.
    #
    # OUTPUT:
    #     There is no return value.
    #
    # PROCESS:
    #     If you remember, we actually hand the
    #     program the start of the memory that they
    #     can use, which is 16 storage locations
    #     after the actual start of the memory
    #     region. All we have to do is go back 16
    #     locations and mark that memory as
    #     available, so that the allocate function
    #     knows it can use it.
    #
        .globl deallocate
        .type  deallocate,   @function

deallocate:         # Since the function is so simple,
                    # we don't need any of the fancy
                    # function stuff.

    subq  $HEADER_SIZE, %rdi
                            # Get the pointer to the
                            # real beginning of the
                            # memory.

    movq  $AVAILABLE, HDR_AVAIL_OFFSET(%rdi)
                            # Mark it as available.

    ret                     # Return.
    # ----- END OF FUNCTION ----- #
