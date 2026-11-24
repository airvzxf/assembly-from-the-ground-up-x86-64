# Example programs

Run `./make.bash` in this directory to assemble and link every example,
then `./test.bash` to run them and compare their results with the values
the book explains. The files with the suffix `-bin` are the executables.

## 64-bit programs

The x86-64 edition replaces the 32-bit programs chapter by chapter (see
`PORTING.md` at the root of the repository). In `make.bash`, a 64-bit
program is assembled with `assemble64` (`as --64 -g`) and linked with
`link64` or `link64_shared` (`ld --fatal-warnings`). The build stops if a
program breaks one of these rules:

- The source has a `.note.GNU-stack` section, so the stack is not
  executable:

  ```gnuassembler
          .section .note.GNU-stack,"",@progbits
  ```

- Data is reached relative to `%rip` (`movq value(%rip), %rax`,
  `leaq table(%rip), %rbx`), never through an absolute 32-bit address, so
  the code also works in PIE programs and shared libraries. A source that
  shows absolute addressing on purpose is listed in `ABSOLUTE_OK`.
- Every program and library is a 64-bit x86-64 ELF file with a
  non-executable stack.

Every 64-bit program also needs a test in `test.bash` before it is
included in the book.
