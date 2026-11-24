# Writing the x86-64 Edition

This repository starts from the x86 32-bit edition (version 3.0), but the
x86-64 edition is a new book, not a mechanical conversion. The reader learns
how 64-bit Linux programs are written today and never needs the 32-bit
material. This file records the decisions and tracks the work, one block
(one pull request) at a time. Tick a block when its pull request is merged.

## Rules

- Every example program is assembled, linked and run by
  `src/resource/asm/make.bash` and `src/resource/asm/test.bash` before it
  enters the book.
- The text stays under the GFDL and the code under the AGPL-3.0. Keep the
  attribution to Jonathan Bartlett, the copyright page and the Document
  History (Appendix G).
- Technical sources: the x86-64 psABI, the Linux man pages, the Intel and
  AMD manuals and the binutils documentation.
- Nothing is merged without the maintainer's approval.

## Decisions

- **Platform**: Linux x86-64, AT&T syntax with the GNU Assembler, the
  `syscall` instruction and the System V AMD64 calling convention.
- **Audience**: the book does not assume the reader knows C. Comparisons
  use current languages, mainly Rust and Python. C appears only where it
  is unavoidable: the system calling convention is still called the "C
  ABI" (Rust declares it with `extern "C"`), and the book explains why.
- **Addressing**: `%rip`-relative from Chapter 2 (`leaq data(%rip), %rbx`,
  then `(%rbx,%rdi,8)`), so every program also works as PIE and in shared
  libraries. Chapter 3 has a box that explains why absolute indexed
  addressing (`data_items(,%rdi,8)`) only works in non-PIE programs.
- **Data size**: `.quad` and the `q` suffix are the norm. Smaller sizes
  appear only where the size is the lesson (bytes, text, buffers, Chapter
  10). The Chapter 6 record grows to 328 bytes (age is 8 bytes, at offset
  320); its offset tables and solutions change in the same pull request.
- **Stack frames**: the book's functions keep the `%rbp` frame. Chapter 12
  adds a note on omitting the frame pointer (`-fomit-frame-pointer`, and
  the Rust equivalent), its benefits and its cost for profiling and
  debugging.
- **Appendix A**: port the GUI example to GTK 4 (`GtkApplication` and its
  `activate` signal). GTK 3 is the fallback only if GTK 4 turns out to be
  disproportionately longer.
- **ABI reference**: link to the x86-64 psABI; `abi386-4.pdf` is removed.
- **Current practice**: every source file has a `.note.GNU-stack` section
  (no executable stack), files are opened with `openat`, and the text
  mentions ASLR, NX and CET where they matter. Tools: `strace`,
  `objdump`, `readelf`, gdb (with its TUI) and `perf`.

## Conventions used everywhere

- System calls: number in `%rax`; arguments in `%rdi`, `%rsi`, `%rdx`,
  `%r10`, `%r8`, `%r9`; `syscall` overwrites `%rcx` and `%r11`; the result
  (or `-errno`) comes back in `%rax`. Numbers used: `read` 0, `write` 1,
  `close` 3, `mmap` 9, `brk` 12, `exit` 60, `openat` 257.
- Functions: arguments in `%rdi`, `%rsi`, `%rdx`, `%rcx`, `%r8`, `%r9`;
  result in `%rax`; the callee preserves `%rbx`, `%rbp`, `%r12`–`%r15`;
  `%rsp` is a multiple of 16 at every `call`; variadic functions such as
  `printf` take the number of vector registers used in `%al`.
- Process start: `(%rsp)` is argc, `8(%rsp)` is argv[0], and so on.
- Build: `as --64 -g` and `ld`; the dynamic linker is
  `/lib64/ld-linux-x86-64.so.2`.

## Blocks

- [ ] **1. Infrastructure**: 64-bit build and checks in `make.bash` and
  `test.bash` (ELF64, no executable stack, no absolute relocations).
  The 32-bit programs keep building until their chapter replaces them;
  `gcc-multilib` is removed in block 11.
- [ ] **2. Chapters 1–3 and Appendix C** (system call table), solutions
  for Chapters 2 and 3. Programs: exit, maximum; 6 solutions.
- [ ] **3. Chapter 4** (System V convention, frames, alignment, recursion),
  solutions. Programs: power, factorial; 4 solutions.
- [ ] **4. Chapter 5** (files, argv, buffers), solutions. Programs: toupper;
  5 solutions.
- [ ] **5. Chapters 6 and 7** (records of 328 bytes, robust programs),
  solutions. Programs: the record library, add-year, error-exit;
  9 solutions.
- [ ] **6. Chapter 8** (libc, shared libraries, PIC, calling assembly from
  Rust and Python), solutions. Adds pinned Rust to the build.
- [ ] **7. Chapter 9** (64-bit memory map, ASLR, `brk` and `mmap`, the
  memory manager with 16-byte headers), solutions.
- [ ] **8. Chapter 10** (64-bit integers, `divq`/`cqto`, SSE2 floating
  point), solutions.
- [ ] **9. Chapters 11–13** (Rust and Python compared with assembly,
  `rustc --emit asm`, `perf`, the frame-pointer note, an updated reading
  list), solutions.
- [ ] **10. Appendices B, E and F, then A** (instructions, high-level
  language idioms, gdb sessions captured from the 64-bit programs, GTK 4).
- [ ] **11. Close-out**: Chapter 1, Appendices J and G, README, remove
  `gcc-multilib` and every 32-bit program, PDF and ePUB, release tag,
  custom domain `asm64.rovisoft.net` on Cloudflare Pages.
