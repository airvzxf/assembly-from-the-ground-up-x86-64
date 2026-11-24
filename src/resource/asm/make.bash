#!/usr/bin/env bash
set -Eeuo pipefail

# Get script directory to handle relative paths correctly
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

# Clean up previous files
rm -f ./*.o
rm -f ./*-bin
rm -f ./*.so .gdb_history heynow.txt

# =====================================================
# 64-bit programs (x86-64 edition).
# =====================================================
#
# Every source is assembled with `as --64 -g` and must follow the rules
# of the book, which the build checks:
#
#   - It has a `.note.GNU-stack` section, so the stack is not executable.
#   - Its code and data use no absolute 32-bit addresses (R_X86_64_32 and
#     R_X86_64_32S relocations in .rela.text, .rela.data, .rela.rodata
#     and their subsections): data is reached relative to %rip, so the
#     code also works in PIE programs and shared libraries. A source that
#     shows absolute addressing on purpose is listed in ABSOLUTE_OK and
#     explains why in a comment that starts with `# ABSOLUTE_OK:`.
#   - Every program and library is a 64-bit ELF file (ELF64, x86-64)
#     whose stack is not executable.
#
# ld runs with --fatal-warnings, so a warning (for example, an executable
# stack) stops the build.

# Sources allowed to use absolute addresses (non-PIE examples).
ABSOLUTE_OK=(003-03-maximum-absolute)

fail_build() {
  echo "error: $*" >&2
  exit 1
}

# absolute_relocations <object>: print the R_X86_64_32 and R_X86_64_32S
# relocations of the code and data sections. Other sections, such as the
# debug sections that -g adds, use 32-bit offsets of their own.
absolute_relocations() {
  readelf -rW "$1" | awk '
    /^Relocation section/ {
      checked = ($3 ~ /^\047\.rela\.(text|data|rodata)[.\047]/)
    }
    checked && $3 ~ /^R_X86_64_32S?$/ { print }'
}

# assemble64 <name>...: assemble <name>.s into <name>.o and check it.
assemble64() {
  local name
  for name in "$@"; do
    echo "Assembling (64-bit): ${name}"
    as --64 -g -o "${name}.o" "${name}.s"
    readelf -SW "${name}.o" | grep -q '\.note\.GNU-stack' \
      || fail_build "${name}.s has no .note.GNU-stack section"
    if [[ " ${ABSOLUTE_OK[*]} " == *" ${name} "* ]]; then
      grep -qE '^[[:space:]]*#[[:space:]]*ABSOLUTE_OK:[[:space:]]*[^[:space:]]' \
        "${name}.s" \
        || fail_build "${name}.s is in ABSOLUTE_OK but has no" \
             "'# ABSOLUTE_OK: <reason>' comment"
    elif [[ -n "$(absolute_relocations "${name}.o")" ]]; then
      fail_build "${name}.s uses absolute addresses; use %rip-relative" \
        "addressing or list it in ABSOLUTE_OK"
    fi
  done
}

# check_elf64 <file>: a 64-bit x86-64 ELF file with a non-executable stack.
check_elf64() {
  readelf -hW "$1" | grep -q 'Class:[[:space:]]*ELF64' \
    || fail_build "$1 is not a 64-bit ELF file"
  readelf -hW "$1" | grep -q 'Machine:[[:space:]]*Advanced Micro Devices X86-64' \
    || fail_build "$1 is not an x86-64 file"
  if readelf -lW "$1" | awk '$1 == "GNU_STACK" && $(NF-1) ~ /E/ { found = 1 }
                             END { exit !found }'; then
    fail_build "$1 has an executable stack"
  fi
}

# link64 <program> <object or ld option>...: link <program>-bin.
link64() {
  local program="$1"
  shift
  echo "Linking (64-bit): ${program}"
  ld --fatal-warnings -o "${program}-bin" "$@"
  check_elf64 "${program}-bin"
}

# link64_shared <library>.so <object or ld option>...: link a library.
link64_shared() {
  local library="$1"
  shift
  echo "Linking (64-bit): ${library}"
  ld --fatal-warnings -shared -o "${library}" "$@"
  check_elf64 "${library}"
}

# The 64-bit programs are added here, chapter by chapter, as they replace
# the 32-bit programs below.

# ----- Chapter 3 -----
assemble64 003-01-exit 003-02-maximum 003-03-maximum-absolute
link64 003-01-exit 003-01-exit.o
link64 003-02-maximum 003-02-maximum.o
link64 003-03-maximum-absolute 003-03-maximum-absolute.o

# ----- Chapter 4 -----
assemble64 004-01-power 004-02-factorial
link64 004-01-power 004-01-power.o
link64 004-02-factorial 004-02-factorial.o

# ----- Appendix K, Chapters 3 and 4 -----
for SOURCE in 0AK-03-*.s 0AK-04-*.s; do
  assemble64 "${SOURCE%.s}"
  link64 "${SOURCE%.s}" "${SOURCE%.s}.o"
done

echo ""

# =====================================================
# 32-bit programs inherited from the x86 32-bit edition.
# =====================================================
# Each chapter of the x86-64 edition removes its programs from here.

# -----------------------------------------------------
# Compile all the files.
# -----------------------------------------------------

FILES=(
  005-01-toupper
  006-01-add-year
  006-01-count-chars
  006-01-read-record
  006-01-read-records
  006-01-write-newline
  006-01-write-record
  006-01-write-records
  007-01-error-exit
  007-01-add-year
  008-01-hello-world-lib
  008-01-hello-world-nolib
  008-02-printf-example
  009-01-memory-layout
  009-02-alloc
  009-02-read-records
  010-01-shift-bit
  010-02-conversion-program
  010-02-integer-to-string
  0AA-01-gnome-example
)

for FILE in "${FILES[@]}"
do
    echo "Assembling: ${FILE}"
    as -o "${FILE}.o" "${FILE}.s" --32 --gstabs+
done

echo ""

# -----------------------------------------------------
# Link the generic files.
# -----------------------------------------------------

GENERIC_FILES=(
  005-01-toupper
  008-01-hello-world-nolib
  009-01-memory-layout
  010-01-shift-bit
)

for FILE in "${GENERIC_FILES[@]}"
do
    echo "Linking #1: ${FILE}"
    ld -o "${FILE}-bin" "${FILE}.o" -m elf_i386
done

echo ""

# -----------------------------------------------------
# Linked special files.
# -----------------------------------------------------

echo "Linking #2: 006-01-write-records"
ld -o "006-01-write-records-bin" -m elf_i386 \
  "006-01-write-record.o" \
  "006-01-write-records.o"

echo "Linking #2: 006-01-read-records"
ld -o "006-01-read-records-bin" -m elf_i386 \
  "006-01-count-chars.o" \
  "006-01-read-record.o" \
  "006-01-read-records.o" \
  "006-01-write-newline.o"

echo "Linking #2: 006-01-add-year"
ld -o "006-01-add-year-bin" -m elf_i386 \
  "006-01-add-year.o" \
  "006-01-read-record.o" \
  "006-01-write-record.o"

echo "Linking #2: 007-01-add-year"
ld -o "007-01-add-year-bin" -m elf_i386 \
  "006-01-count-chars.o" \
  "006-01-read-record.o" \
  "006-01-write-newline.o" \
  "006-01-write-record.o" \
  "007-01-add-year.o" \
  "007-01-error-exit.o"

echo "Linking #2: 008-01-hello-world-lib"
ld -o "008-01-hello-world-lib-bin" -m elf_i386 \
  "008-01-hello-world-lib.o" \
  --library c \
  --library-path /usr/lib32/ \
  -dynamic-linker /usr/lib32/ld-linux.so.2

echo "Linking #2: 008-02-printf-example"
ld -o "008-02-printf-example-bin" -m elf_i386 \
  "008-02-printf-example.o" \
  --library c \
  --library-path /usr/lib32/ \
  -dynamic-linker /usr/lib32/ld-linux.so.2

echo "Linking #2: librecord.so"
ld -o "librecord.so" -m elf_i386 \
  -shared \
  "006-01-read-record.o" \
  "006-01-write-record.o"

echo "Linking #2: 008-03-write-records"
ld -o "008-03-write-records-bin" -m elf_i386 \
  "006-01-write-records.o" \
  --library record \
  --library-path . \
  -dynamic-linker /usr/lib32/ld-linux.so.2

echo "Linking #2: 009-02-read-records"
ld -o "009-02-read-records-bin" -m elf_i386 \
  "006-01-count-chars.o" \
  "006-01-read-record.o" \
  "006-01-write-newline.o" \
  "009-02-alloc.o" \
  "009-02-read-records.o"

echo "Linking #2: 010-02-conversion-program"
ld -o "010-02-conversion-program-bin" -m elf_i386 \
  "006-01-count-chars.o" \
  "006-01-write-newline.o" \
  "010-02-conversion-program.o" \
  "010-02-integer-to-string.o"

echo ""

echo "Linking #3: 011-01-hello-world-c"
gcc -o "011-01-hello-world-c-bin" "011-01-hello-world.c"

# -----------------------------------------------------
# Solutions to the review questions (Appendix K).
# -----------------------------------------------------

for SOURCE in 0AK-*.s
do
    [[ "${SOURCE}" == 0AK-0[34]-* ]] && continue  # 64-bit.
    echo "Assembling: ${SOURCE%.s}"
    as -o "${SOURCE%.s}.o" "${SOURCE}" --32 --gstabs+
done

# Link a solution: link_solution <program> [extra objects/options...]
link_solution() {
    local PROGRAM="$1"
    shift
    echo "Linking #4: ${PROGRAM}"
    ld -o "${PROGRAM}-bin" -m elf_i386 "${PROGRAM}.o" "$@"
}

LIBC=(--library c --library-path /usr/lib32/
      -dynamic-linker /usr/lib32/ld-linux.so.2)

for SOURCE in 0AK-05-03-*.s
do
    link_solution "${SOURCE%.s}"
done

link_solution 0AK-05-01-toupper-stdio 0AK-05-00-convert-to-upper.o
link_solution 0AK-05-02-toupper-bss 0AK-05-00-convert-to-upper.o
link_solution 0AK-05-04-toupper-checked \
  0AK-05-00-convert-to-upper.o 006-01-count-chars.o

link_solution 0AK-06-01-write-records 0AK-06-01-record-io.o
link_solution 0AK-06-01-read-records 0AK-06-01-record-io.o \
  006-01-count-chars.o 006-01-write-newline.o
link_solution 0AK-06-02-write-30-records 006-01-write-record.o
link_solution 0AK-06-03-max-age 006-01-read-record.o
link_solution 0AK-06-04-min-age 006-01-read-record.o
link_solution 0AK-06-05-add-year-in-place \
  006-01-read-record.o 006-01-write-record.o
link_solution 0AK-06-07-find-records 0AK-06-06-compare-strings.o \
  006-01-read-record.o 006-01-count-chars.o 006-01-write-newline.o

link_solution 0AK-07-01-add-year-robust \
  006-01-read-record.o 006-01-write-record.o 007-01-error-exit.o \
  006-01-count-chars.o 006-01-write-newline.o

echo "Linking #4: libfactorial.so"
ld -shared -m elf_i386 -o libfactorial.so 0AK-08-01-factorial-lib.o
link_solution 0AK-08-02-factorial-printf \
  --library-path . --library factorial "${LIBC[@]}"
link_solution 0AK-08-03-toupper-libc 0AK-05-00-convert-to-upper.o \
  "${LIBC[@]}"
echo "Linking #4: libexitmsg.so"
ld -shared -m elf_i386 -o libexitmsg.so 0AK-08-04-exit-message.o

link_solution 0AK-09-02-alloc-test 0AK-09-01-alloc.o
echo "Linking #4: 0AK-09-02-alloc-test-book (with 009-02-alloc.o)"
ld -o 0AK-09-02-alloc-test-book-bin -m elf_i386 \
  0AK-09-02-alloc-test.o 009-02-alloc.o
link_solution 0AK-09-03-alloc-auto-init 0AK-09-01-alloc.o

link_solution 0AK-10-02-print-numbers 0AK-10-01-integer2string-base.o \
  0AK-08-01-factorial-lib.o 006-01-write-newline.o
link_solution 0AK-10-03-is-negative
link_solution 0AK-10-04-number2integer \
  0AK-10-01-integer2string-base.o 006-01-write-newline.o
link_solution 0AK-10-05-likes

echo "Linking #4: 0AK-11-01-maximum-c"
gcc -o 0AK-11-01-maximum-c-bin 0AK-11-01-maximum.c


echo ""

echo "Example compilation completed."