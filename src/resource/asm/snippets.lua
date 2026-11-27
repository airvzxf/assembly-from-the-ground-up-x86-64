-- Named snippets of the example sources, shown in the book with
-- `snippet=<name>` instead of line numbers. Each snippet starts at
-- the line whose text (without the spaces at both ends) is `first`
-- and ends at the next line whose text is `last` (by default the
-- same as `first`). When a text appears more than once, `first_n`
-- or `last_n` says which one: the n-th in the file for `first`, the
-- n-th from the first line for `last`. The build fails if a text is
-- missing, or if `first` appears more than once and has no `first_n`.
-- Read by resource/pandoc/lua/include-code-files.lua.

return {
  ["003-01-exit-section-note-gnu"] = {
    file = "003-01-exit.s",
    first = [==[.section .note.GNU-stack,"",@progbits]==],
  },
  ["003-01-exit-section-data"] = {
    file = "003-01-exit.s",
    first = [==[.section .data]==],
  },
  ["003-01-exit-section-text"] = {
    file = "003-01-exit.s",
    first = [==[.section .text]==],
  },
  ["003-01-exit-globl-start"] = {
    file = "003-01-exit.s",
    first = [==[.globl _start]==],
  },
  ["003-01-exit-start"] = {
    file = "003-01-exit.s",
    first = [==[_start:]==],
  },
  ["003-01-exit-movq-60-rax"] = {
    file = "003-01-exit.s",
    first = [==[movq $60, %rax     # This is the Linux kernel]==],
    last = [==[# for exiting a program.]==],
  },
  ["003-01-exit-movq-0-rdi"] = {
    file = "003-01-exit.s",
    first = [==[movq $0, %rdi      # This is the status number we]==],
    last = [==[# things to `echo $?`.]==],
  },
  ["003-01-exit-syscall-this-wakes"] = {
    file = "003-01-exit.s",
    first = [==[syscall            # This wakes up the kernel to]==],
    last = [==[# run the exit command.]==],
  },
  ["003-02-maximum-data-items"] = {
    file = "003-02-maximum.s",
    first = [==[.section .data]==],
    last = [==[.quad 3, 67, 34, 222, 45, 22, 11, 125, 0]==],
  },
  ["003-02-maximum-leaq-data-items"] = {
    file = "003-02-maximum.s",
    first = [==[leaq data_items(%rip), %rbx  # Address of the]==],
    last = [==[# list.]==],
  },
  ["003-02-maximum-movq-0-rcx"] = {
    file = "003-02-maximum.s",
    first = [==[movq $0, %rcx           # Move 0 into the index]==],
    last = [==[# register.]==],
  },
  ["003-02-maximum-movq-rbx-rcx"] = {
    file = "003-02-maximum.s",
    first = [==[movq (%rbx,%rcx,8), %rax  # Load the first]==],
    last = [==[# data item.]==],
  },
  ["003-02-maximum-movq-rax-rdi"] = {
    file = "003-02-maximum.s",
    first = [==[movq %rax, %rdi         # Since this is the first]==],
    last = [==[# item, %rax is the biggest]==],
  },
  ["003-02-maximum-cmpq-0-rax"] = {
    file = "003-02-maximum.s",
    first = [==[cmpq $0, %rax           # Check to see if we have]==],
    last = [==[je _loop_exit           # hit the end.]==],
  },
  ["003-02-maximum-incq-rcx-increment"] = {
    file = "003-02-maximum.s",
    first = [==[incq %rcx               # Increment %rcx by 1.]==],
    last = [==[movq (%rbx,%rcx,8), %rax  # Load next value.]==],
  },
  ["003-02-maximum-cmpq-rdi-rax"] = {
    file = "003-02-maximum.s",
    first = [==[cmpq %rdi, %rax         # Compare values.]==],
    last = [==[# the new one is not bigger]==],
  },
  ["003-02-maximum-movq-rax-rdi-2"] = {
    file = "003-02-maximum.s",
    first = [==[movq %rax, %rdi         # Move the value as the]==],
    last = [==[jmp _start_loop         # Jump to loop beginning.]==],
  },
  ["003-02-maximum-loop-exit"] = {
    file = "003-02-maximum.s",
    first = [==[_loop_exit:]==],
    last = [==[# exit() system call.]==],
  },
  ["004-01-power-type-power"] = {
    file = "004-01-power.s",
    first = [==[.type power, @function]==],
  },
  ["004-01-power-power"] = {
    file = "004-01-power.s",
    first = [==[power:]==],
  },
  ["004-01-power-pushq-rbp-save"] = {
    file = "004-01-power.s",
    first = [==[pushq %rbp              # Save old base pointer.]==],
    last = [==[# to 16).]==],
  },
  ["004-02-factorial-start"] = {
    file = "004-02-factorial.s",
    first = [==[_start:]==],
    last = [==[# function.]==],
  },
  ["004-02-factorial-movq-rax-rdi"] = {
    file = "004-02-factorial.s",
    first = [==[movq %rax, %rdi         # factorial returns the]==],
    last = [==[syscall                 # function.]==],
  },
  ["004-02-factorial-factorial"] = {
    file = "004-02-factorial.s",
    first = [==[.type factorial, @function]==],
    last = [==[factorial:]==],
  },
  ["004-02-factorial-pushq-rbp-standard"] = {
    file = "004-02-factorial.s",
    first = [==[pushq %rbp              # Standard function stuff]==],
    last = [==[# aligned to 16.]==],
  },
  ["004-02-factorial-movq-rdi-rax"] = {
    file = "004-02-factorial.s",
    first = [==[movq  %rdi, %rax        # If the number is 1, that]==],
    last = [==[# return value).]==],
  },
  ["004-02-factorial-movq-rdi-8"] = {
    file = "004-02-factorial.s",
    first = [==[movq  %rdi, -8(%rbp)    # Save our number in a]==],
    last = [==[# below may overwrite %rdi.]==],
  },
  ["004-02-factorial-decq-rdi-decrease"] = {
    file = "004-02-factorial.s",
    first = [==[decq  %rdi              # Decrease the number.]==],
    last = [==[# number minus one.]==],
  },
  ["004-02-factorial-imulq-8-rbp"] = {
    file = "004-02-factorial.s",
    first = [==[imulq -8(%rbp), %rax    # Multiply our number by]==],
    last = [==[# return values go.]==],
  },
  ["004-02-factorial-end-factorial"] = {
    file = "004-02-factorial.s",
    first = [==[end_factorial:]==],
    last = [==[# the function started.]==],
  },
  ["004-02-factorial-ret-return-from"] = {
    file = "004-02-factorial.s",
    first = [==[ret                     # Return from the function]==],
    last = [==[# address, too).]==],
  },
  ["005-01-toupper-equ-lowercase-a"] = {
    file = "005-01-toupper.s",
    first = [==[# ----- CONSTANTS ----- #]==], first_n = 2,
    last = [==[.equ  UPPER_CONVERSION,  'A' - 'a']==],
  },
  ["005-01-toupper-movq-0-rcx"] = {
    file = "005-01-toupper.s",
    first = [==[movq  $0, %rcx]==],
  },
  ["005-01-toupper-cmpq-0-rsi"] = {
    file = "005-01-toupper.s",
    first = [==[cmpq  $0, %rsi          # If a buffer with zero]==],
    last = [==[je    end_convert_loop]==],
  },
  ["005-01-toupper-get-the-current"] = {
    file = "005-01-toupper.s",
    first = [==[# Get the current byte.]==],
    last = [==[movb  (%rdi,%rcx,1), %al]==],
  },
  ["006-01-write-records-include-006-01"] = {
    file = "006-01-write-records.s",
    first = [==[.include "006-01-linux.s"      # Linux Definitions.]==],
    last = [==[.include "006-01-record-def.s" # Record definitions]==],
  },
  ["006-01-write-records-if-record2-record1"] = {
    file = "006-01-write-records.s",
    first = [==[.if (record2 - record1) != RECORD_SIZE]==],
    last = [==[.endif]==], last_n = 3,
  },
  ["006-01-read-records-leaq-record-buffer"] = {
    file = "006-01-read-records.s",
    first = [==[leaq  record_buffer + RECORD_FIRSTNAME(%rip), %rdi]==],
  },
  ["007-01-add-year-no-open-file"] = {
    file = "007-01-add-year.s",
    first = [==[movq  $SYS_OPENAT, %rax # Open file for reading.]==],
    last = [==[continue_processing:]==],
  },
  ["008-01-hello-world-lib-leaq-helloworld-rip"] = {
    file = "008-01-hello-world-lib.s",
    first = [==[leaq  helloworld(%rip), %rdi]==],
    last = [==[call  printf@PLT]==],
  },
  ["009-01-memory-layout-movq-sys-brk"] = {
    file = "009-01-memory-layout.s",
    first = [==[movq  $SYS_BRK, %rax    # brk(0) returns the]==],
    last = [==[syscall                 # up: this is the heap.]==],
  },
  ["009-01-memory-layout-movq-sys-mmap"] = {
    file = "009-01-memory-layout.s",
    first = [==[movq  $SYS_MMAP, %rax   # mmap(0, PAGE_SIZE,]==],
    last = [==[syscall                 # Linux picks the address.]==],
  },
  ["009-02-alloc-heap-begin"] = {
    file = "009-02-alloc.s",
    first = [==[heap_begin:         # This points to the]==],
    last = [==[# we are managing.]==], last_n = 2,
  },
  ["009-02-alloc-equ-header-size"] = {
    file = "009-02-alloc.s",
    first = [==[# ----- STRUCTURE INFORMATION ----- #]==],
    last = [==[# header.]==], last_n = 2,
  },
  ["009-02-alloc-equ-unavailable"] = {
    file = "009-02-alloc.s",
    first = [==[# ----- CONSTANTS ----- #]==],
    last = [==[# giving.]==],
  },
  ["009-02-alloc-allocate-init"] = {
    file = "009-02-alloc.s",
    first = [==[allocate_init:]==],
    last = [==[# memory of the program.]==],
  },
  ["009-02-alloc-addq-15-rax"] = {
    file = "009-02-alloc.s",
    first = [==[addq  $15, %rax         # Round it up to a multiple]==],
    last = [==[ret]==],
  },
  ["009-02-alloc-allocate"] = {
    file = "009-02-alloc.s",
    first = [==[allocate:]==],
    last = [==[# current break.]==],
  },
  ["009-02-alloc-alloc-loop-begin"] = {
    file = "009-02-alloc.s",
    first = [==[alloc_loop_begin:           # Here we iterate through]==],
    last = [==[je    move_break        # are equal.]==],
  },
  ["009-02-alloc-move-break"] = {
    file = "009-02-alloc.s",
    first = [==[move_break:         # If we have made it here, that]==],
    last = [==[syscall                 # for more memory.]==],
  },
  ["009-02-alloc-under-normal-conditions"] = {
    file = "009-02-alloc.s",
    first = [==[# Under normal conditions,]==],
    last = [==[jne   error             # conditions.]==],
  },
  ["009-02-alloc-set-this-memory"] = {
    file = "009-02-alloc.s",
    first = [==[# Set this memory as]==],
    last = [==[ret]==],
  },
  ["009-02-alloc-movq-hdr-size"] = {
    file = "009-02-alloc.s",
    first = [==[movq  HDR_SIZE_OFFSET(%rax), %r8]==],
    last = [==[# next one.]==],
  },
  ["009-02-alloc-cmpq-r8-rdx"] = {
    file = "009-02-alloc.s",
    first = [==[cmpq  %r8, %rdx         # If the space is]==],
    last = [==[# allocate_here.]==],
  },
  ["009-02-alloc-allocate-here"] = {
    file = "009-02-alloc.s",
    first = [==[allocate_here:      # If we have made it here, that]==],
    last = [==[ret]==],
  },
  ["009-02-alloc-next-location"] = {
    file = "009-02-alloc.s",
    first = [==[next_location:]==],
    last = [==[# location.]==],
  },
  ["009-02-alloc-deallocate"] = {
    file = "009-02-alloc.s",
    first = [==[deallocate:         # Since the function is so simple,]==],
    last = [==[ret                     # Return.]==],
  },
  ["006-01-read-records-section-bss"] = {
    file = "006-01-read-records.s",
    first = [==[.section .bss]==],
    last = [==[.lcomm record_buffer,  RECORD_SIZE]==],
  },
  ["009-02-read-records-record-buffer-ptr"] = {
    file = "009-02-read-records.s",
    first = [==[record_buffer_ptr:]==],
    last = [==[.quad 0]==],
  },
  ["009-02-read-records-call-allocate-init"] = {
    file = "009-02-read-records.s",
    first = [==[call  allocate_init]==],
  },
  ["009-02-read-records-movq-record-size"] = {
    file = "009-02-read-records.s",
    first = [==[movq  $RECORD_SIZE, %rdi]==],
    last = [==[movq  %rax, record_buffer_ptr(%rip)]==],
  },
  ["006-01-read-records-leaq-record-buffer-2"] = {
    file = "006-01-read-records.s",
    first = [==[leaq  record_buffer(%rip), %rsi]==],
  },
  ["009-02-read-records-movq-record-buffer"] = {
    file = "009-02-read-records.s",
    first = [==[movq  record_buffer_ptr(%rip), %rsi]==], first_n = 1,
  },
  ["009-02-read-records-movq-record-buffer-2"] = {
    file = "009-02-read-records.s",
    first = [==[movq  record_buffer_ptr(%rip), %rdi]==], first_n = 1,
    last = [==[addq  $RECORD_FIRSTNAME, %rdi]==],
  },
  ["006-01-read-records-leaq-record-buffer-3"] = {
    file = "006-01-read-records.s",
    first = [==[leaq  record_buffer + RECORD_FIRSTNAME(%rip), %rsi]==],
  },
  ["009-02-read-records-movq-record-buffer-3"] = {
    file = "009-02-read-records.s",
    first = [==[movq  record_buffer_ptr(%rip), %rsi]==], first_n = 2,
    last = [==[addq  $RECORD_FIRSTNAME, %rsi]==],
  },
  ["009-02-read-records-movq-record-buffer-4"] = {
    file = "009-02-read-records.s",
    first = [==[movq  record_buffer_ptr(%rip), %rdi]==], first_n = 2,
    last = [==[call  deallocate]==],
  },
}
