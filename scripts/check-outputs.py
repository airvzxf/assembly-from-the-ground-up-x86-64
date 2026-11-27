#!/usr/bin/env python3
"""Check the program and tool outputs that the book shows.

Every output in the book that comes from running something is a fenced
block with a `check` attribute (and the class `.text`: without a class,
Quarto would take the block for code to execute):

    ```{.text check=ch05-strace-toupper}
    openat(AT_FDCWD, "input.txt", O_RDONLY) = 3
    ```

This script runs the command of each check (the table CHECKS below) in a
copy of src/resource/asm where the programs built by make.bash have their
book names (`003-02-maximum`, not `003-02-maximum-bin`), and compares its
output with the block:

- Spaces are collapsed, and blank lines don't count.
- Values that change from run to run (addresses chosen by ASLR, device
  and inode numbers, the pointer and size of the environment, the
  directory) are replaced by placeholders on both sides.
- A line `...` in the book skips lines of the output; ` ... ` inside a
  line skips part of it. Lines that start with `(gdb)` are the commands
  of a gdb session: the script runs them, and doesn't compare them.
- Without `...`, the block must be the whole output. With it, or in gdb
  sessions, the lines of the book must appear in the output in the same
  order.

Not checked: the `perf` outputs of Chapter 12 (their numbers change in
every run, and `perf` needs a kernel that allows it) and the control-c
of Appendix F (it stops at a different line every time).

Run src/resource/asm/make.bash first. `setarch -R` (Chapter 9) needs
the personality system call: run the container with
`--security-opt seccomp=unconfined`.
Without it that check is skipped, except in CI, where a skip fails.

Usage: check-outputs.py [check name...]
"""

import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

BOOK = Path(__file__).resolve().parent.parent / "src"
HERE = BOOK / "resource" / "asm"
WORK = "/tmp/w"  # The directory the book's captures were made in.

# ----- Normalization -----

COMMON = [
    # Addresses near the top of the user address space (stack,
    # libraries, vdso, mmap) change with ASLR, the environment and the
    # kernel. ASLR moves the mmap area down by up to 2^40 bytes, so they
    # can start with 7e as well as 7f: any 12 digits that start with 7.
    (r"\b(0x(?:0000)?)?7[0-9a-f]{11}\b", r"\g<1><aslr>"),
]
ENVP = (r"0x[0-9a-f]+ /\* \d+ vars \*/", "<envp>")
BRK = (r"\b0x[0-9a-f]{6,8}\b", "<brk>")
# /proc/self/maps: device and inode of the file, and the random heap.
MAPS = [
    (r"^(\S+ \S+ [0-9a-f]+) [0-9a-f]+:[0-9a-f]+ [1-9]\d*",
     r"\1 <dev> <inode>"),
    (r"^[0-9a-f]+-[0-9a-f]+ (rw-p 00000000 00:00 0 \[heap\])", r"<heap> \1"),
]


def normalize(text, subs):
    lines = []
    for line in text.splitlines():
        line = " ".join(line.split())
        if not line:
            continue
        for pattern, replacement in subs + COMMON:
            line = re.sub(pattern, replacement, line)
        lines.append(line)
    return lines


def line_regex(line):
    parts = [re.escape(part) for part in line.split(" ... ")]
    return re.compile(".*".join(parts))


def compare(book, actual, subset, partial, optional):
    """Return None if the book lines match the output, else the reason."""
    if not subset and len(book) != len(actual):
        return f"the book has {len(book)} lines, the output {len(actual)}"
    position = 0
    for line in book:
        regex = line_regex(line)
        match = regex.search if partial else regex.fullmatch
        if not subset:
            if not match(actual[position]):
                return f"book:   {line}\noutput: {actual[position]}"
            position += 1
            continue
        for index in range(position, len(actual)):
            if match(actual[index]):
                position = index + 1
                break
        else:
            if any(re.search(o, line) for o in optional):
                continue
            return f"not in the output (in this order): {line}"
    return None


# ----- The checks -----

def sh(command):
    return {"sh": command}


def gdb(program, *prelude, args=""):
    return {"gdb": program, "prelude": list(prelude), "args": args}


MAXIMUM = ("as -o 003-02-maximum.o 003-02-maximum.s"
           " && ld -o 003-02-maximum 003-02-maximum.o && ./003-02-maximum")
RUST_STRUCTS = ("rustc --edition 2024 -C opt-level=2 --emit asm"
                " 0AM-02-structs.rs && cat 0AM-02-structs.s")
# Appendix F debugs a 003-02-maximum without its `incq %rcx` line.
BROKEN_MAXIMUM = (
    "sed -i '/incq  *%rcx/d' 003-02-maximum.s"
    " && as --64 -g -o 003-02-maximum.o 003-02-maximum.s"
    " && ld -o 003-02-maximum 003-02-maximum.o"
)
# The snippets of Chapter 10, assembled in a program of their own.
REGISTER_SNIPPET = """\
    .section .note.GNU-stack,"",@progbits
    .text
    .globl _start
_start:
    movq  $-1, %rax
    movl  $5, %eax
    movq  $-1, %rbx
    movw  $5, %bx
done:
    movq  $60, %rax
    movq  $0, %rdi
    syscall
"""
ZERO_SNIPPET = """\
    movq  $0, %rax
    movl  $0, %eax
    xorl  %eax, %eax
    xorq  %rax, %rax
"""

CHECKS = {
    # Chapter 3
    "ch03-objdump-maximum": dict(sh("objdump -d 003-02-maximum"),
                                 subset=True),
    "ch03-pie-absolute": dict(
        sh("ld -pie --no-dynamic-linker -o maximum-pie"
           " 003-03-maximum-absolute.o"), joined=True),
    # Chapter 3: the programs of "When a Program Does Something
    # Strange", each with one change.
    "ch03-strange-300": sh(
        "sed -i 's/quad 3, 67, 34, 222,/quad 3, 67, 34, 300,/'"
        f" 003-02-maximum.s && {MAXIMUM}; echo $?"),
    "ch03-strange-no-dollar": dict(sh(
        "sed -i 's/movq \\$60, %rax/movq 60, %rax/' 003-01-exit.s"
        " && as -o 003-01-exit.o 003-01-exit.s"
        " && ld -o 003-01-exit 003-01-exit.o && ./003-01-exit; echo $?"),
        partial=True),
    "ch03-strange-no-end": sh(
        "sed -i 's/11, 125, 0$/11, 125/' 003-02-maximum.s"
        f" && {MAXIMUM}; echo $?"),
    "ch03-strange-next-data": sh(
        "sed -i 's/11, 125, 0$/11, 125\\n            .quad 255/'"
        f" 003-02-maximum.s && {MAXIMUM}; echo $?"),
    "ch03-strange-no-globl": sh(
        "sed -i '/globl _start/d' 003-01-exit.s"
        " && as -o 003-01-exit.o 003-01-exit.s"
        " && ld -o 003-01-exit 003-01-exit.o"),
    # Chapter 5
    "ch05-hello-world": sh("./005-00-hello-world"),
    "ch05-strace-toupper": dict(
        sh("printf 'Hey diddle diddle,\\nthe cat and the fiddle.\\n'"
           " > input.txt; strace ./005-01-toupper input.txt output.txt"),
        subs=[ENVP]),
    # Chapter 6
    "ch06-hexdump-records": dict(
        sh("./006-01-write-records && hexdump -C test.dat"), subset=True),
    # Chapter 8
    "ch08-readelf-needed": dict(sh("readelf -d 008-01-hello-world-lib"),
                                subset=True),
    "ch08-libc-script": dict(sh("cat /usr/lib/x86_64-linux-gnu/libc.so"),
                             subset=True),
    "ch08-ldd-hello": sh("ldd ./008-01-hello-world-lib"),
    "ch08-printf-alignment": dict(
        gdb("008-02-printf-example", "run", "x/i $pc"),
        setup="sed -i 's/^    call  printf@PLT/    pushq $0\\n&/;"
              " s/^    movq  \\$0, %rax  /    movq  $1, %rax  /'"
              " 008-02-printf-example.s"
              " && as --64 -g -o p.o 008-02-printf-example.s"
              " && ld -o 008-02-printf-example p.o -l c"
              " -dynamic-linker /lib64/ld-linux-x86-64.so.2"),
    "ch08-printf-example": sh("./008-02-printf-example"),
    "ch08-objdump-plt": sh(
        "objdump -d --no-show-raw-insn 008-02-printf-example"),
    "ch08-objdump-r-printf": sh("objdump -R 008-02-printf-example"),
    "ch08-no-librecord": sh("./008-03-write-records"),
    "ch08-ldd-records": sh("LD_LIBRARY_PATH=. ldd ./008-03-write-records"),
    "ch08-objdump-r-records": sh("objdump -R ./008-03-write-records"),
    "ch08-shared-absolute": sh(
        "ld -shared -o absolute.so 003-03-maximum-absolute.o"),
    "ch08-shared-global": sh(
        "sed 's/^        calls:/        .globl calls\\n&/'"
        " 008-04-call-count.s > global.s"
        " && as --64 -g -o global.o global.s"
        " && ld -shared -o libbook.so 006-01-count-chars.o global.o"),
    "ch08-objdump-t-libbook": sh("objdump -T libbook.so"),
    "ch08-use-library-rust": sh("LD_LIBRARY_PATH=. ./008-05-use-library"),
    "ch08-ldd-rust": sh("LD_LIBRARY_PATH=. ldd ./008-05-use-library"),
    # Chapter 9
    "ch09-objdump-lea": dict(sh("objdump -d 003-02-maximum"),
                             subset=True),
    "ch09-gdb-stack": dict(
        gdb("009-01-memory-layout", "starti", args="hello"),
        subs=[(r'"[A-Za-z_][A-Za-z0-9_]*=[^"]*"', '"<environment>"')]),
    "ch09-memory-layout": dict(
        sh("./009-01-memory-layout"), subs=MAPS,
        # Older kernels have no [vvar_vclock] region.
        optional=[r"\[vvar_vclock\]"]),
    "ch09-readelf-segments": sh("readelf -lW 009-01-memory-layout"),
    # Without ASLR the heap is always at the same address: keep it.
    "ch09-setarch": dict(sh("setarch -R ./009-01-memory-layout"),
                         subs=MAPS[:1], subset=True,
                         needs="setarch -R true"),
    "ch09-pie-runs": dict(
        sh("ld -pie --no-dynamic-linker -o 009-01-memory-layout-pie"
           " 009-01-memory-layout.o && for run in 1 2; do"
           " ./009-01-memory-layout-pie | grep 'r-xp.*-pie$'; done"),
        subs=MAPS),
    "ch09-cet-c": dict(sh(
        "printf 'int main(void) { return 0; }\\n' > small.c"
        " && gcc -o small small.c && readelf -n small"), subset=True),
    "ch09-notes-rust": sh("readelf -n 011-01-hello-world"),
    "ch09-cet-report": sh(
        "ld -z cet-report=warning -o 003-01-exit 003-01-exit.o"),
    "ch09-strace-records": dict(
        sh("./006-01-write-records && strace ./009-02-read-records"
           " >/dev/null"),
        subs=[ENVP, BRK]),
    # Chapter 10
    "ch10-objdump-zero": dict(
        sh(f"printf '%s' '{ZERO_SNIPPET}' > zero.s && as -o zero.o zero.s"
           " && objdump -d zero.o"), partial=True, subset=True),
    "ch10-gdb-registers": dict(
        gdb("registers", "break done", "run"),
        setup=f"printf '%s' '{REGISTER_SNIPPET}' > registers.s"
              " && as -g -o registers.o registers.s"
              " && ld -o registers registers.o"),
    "ch10-floating-point": sh("./010-03-floating-point"),
    "ch10-od-age": sh(
        "./006-01-write-records && od -A d -t x1 -j 320 -N 8 test.dat"),
    # Chapter 11
    "ch11-dis-maximum": dict(sh("python3 -m dis 011-02-maximum.py"),
                             subset=True),
    # Chapter 12
    "ch12-gdb-frame-chain": dict(
        gdb("009-02-read-records", "break count_chars", "run",
            "stepi 2"),
        setup="./006-01-write-records"),
    # Appendix B
    "appb-objdump-att": dict(
        sh("objdump -d --no-show-raw-insn 003-02-maximum"), subset=True),
    "appb-objdump-intel": dict(
        sh("objdump -d --no-show-raw-insn -M intel 003-02-maximum"),
        subset=True),
    # Appendix L
    "appl-gdb-flags": gdb("003-02-maximum"),
    # Appendix M
    "appm-gdb-stack-parameters": gdb("0AM-01-sum8"),
    "appm-rust-swap-pair": dict(sh(RUST_STRUCTS), subset=True),
    "appm-rust-rotate-triple": dict(sh(RUST_STRUCTS), subset=True),
    # Appendix N
    "appn-gdb-rip": gdb("003-02-maximum"),
    "appn-objdump-bytes": dict(sh("objdump -d 003-02-maximum"),
                               subset=True),
    # Appendix F
    "appf-start": dict(sh("gdb -nx ./003-02-maximum < /dev/null"),
                       setup=BROKEN_MAXIMUM, subset=True),
    "appf-stepi": dict(gdb("003-02-maximum", "break 40", "run", "delete"),
                       setup=BROKEN_MAXIMUM),
    "appf-print": dict(gdb("003-02-maximum", "break 40", "run"),
                       setup=BROKEN_MAXIMUM),
    "appf-examine": dict(gdb("003-02-maximum", "break 40", "run"),
                         setup=BROKEN_MAXIMUM),
    "appf-info-registers": dict(gdb("003-02-maximum", "break 39", "run"),
                                setup=BROKEN_MAXIMUM),
    "appf-break-line": gdb("004-02-factorial"),
    "appf-nexti": gdb("004-02-factorial", "@appf-break-line"),
    "appf-break-function": gdb("004-02-factorial"),
    "appf-continue": gdb("004-02-factorial", "@appf-break-function",
                         "continue", "continue"),
    "appf-finish": gdb("004-02-factorial", "@appf-continue"),
    # Appendix K
    "appk-strace-missing": dict(
        sh("strace ./005-01-toupper missing.txt output2.txt"),
        subs=[ENVP]),
    "appk-records": sh("./0AK-06-01-write-records"
                       " && ./0AK-06-01-read-records"),
    "appk-maximum-1000": sh(
        "sed -i 's/quad 3, 67,/quad 1000, 67,/' 003-02-maximum.s"
        f" && {MAXIMUM}; echo $?"),
    "appk-hello-stderr": sh(
        "sed -i 's/movq  \\$1, %rdi /movq  $2, %rdi /' 005-00-hello-world.s"
        " && as -o h.o 005-00-hello-world.s && ld -o 005-00-hello-world h.o"
        " && ./005-00-hello-world > /dev/null"),
    "appk-hexdump-third-age": dict(
        sh("./006-01-write-records && hexdump -C test.dat"), subset=True),
    "appk-factorial-python": sh("python3 0AK-08-05-factorial.py"),
    "appk-print-numbers": sh("./0AK-10-02-print-numbers"),
    "appk-celsius": sh("./0AK-10-06-celsius"),
}


# ----- Reading the book -----

FENCE = re.compile(r"^(?P<indent>(?:> ?)?\s*)```+\s*"
                   r"\{[^}]*\bcheck=(?P<name>[\w-]+)[^}]*\}\s*$")


def book_blocks():
    """Return {name: (file, text)} for every block with `check=`."""
    blocks = {}
    for path in sorted(BOOK.glob("*.qmd")):
        lines = path.read_text().splitlines()
        index = 0
        while index < len(lines):
            fence = FENCE.match(lines[index])
            index += 1
            if not fence:
                continue
            prefix = fence["indent"]
            body = []
            while not lines[index].lstrip("> ").startswith("```"):
                line = lines[index]
                body.append(line[len(prefix):] if line.startswith(prefix)
                            else line.lstrip("> "))
                index += 1
            name = fence["name"]
            if name in blocks:
                sys.exit(f"check={name} is used twice")
            blocks[name] = (path.name, "\n".join(body))
    return blocks


def gdb_commands(text):
    return [line[len("(gdb) "):] for line in text.splitlines()
            if line.startswith("(gdb) ")]


# ----- Running -----

def prepare(directory):
    """Copy the built examples into directory, with their book names."""
    for item in HERE.iterdir():
        if item.is_file():
            name = item.name
            if name.endswith("-bin"):
                name = name[:-len("-bin")]
            shutil.copy2(item, directory / name)


def run(name, check, blocks):
    with tempfile.TemporaryDirectory() as temp:
        directory = Path(temp)
        prepare(directory)
        env = {key: value for key, value in os.environ.items()
               if key != "LD_LIBRARY_PATH"}

        def shell(command):
            result = subprocess.run(
                ["bash", "-c", command], cwd=directory, env=env,
                stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                text=True, timeout=60)
            return result.stdout

        if "setup" in check:
            shell(check["setup"] + " >/dev/null 2>&1 || echo SETUP FAILED")
        if "gdb" in check:
            commands = []
            for item in check["prelude"]:
                if item.startswith("@"):
                    commands += expand(item[1:], blocks)
                else:
                    commands.append(item)
            commands += gdb_commands(blocks[name][1])
            arguments = " ".join(f"-ex '{c}'" for c in commands)
            output = shell(f"gdb -q -nx -batch {arguments}"
                           f" --args ./{check['gdb']} {check['args']}")
        else:
            output = shell(check["sh"])
        return output.replace(str(directory), WORK)


def expand(name, blocks):
    """The gdb commands of a check, including the ones before them."""
    check = CHECKS[name]
    commands = []
    for item in check["prelude"]:
        commands += expand(item[1:], blocks) if item.startswith("@") \
            else [item]
    return commands + gdb_commands(blocks[name][1])


def main():
    blocks = book_blocks()
    names = sys.argv[1:] or list(CHECKS)
    failed = False
    for name in sorted(set(blocks) - set(CHECKS)):
        print(f"FAIL {name}: in {blocks[name][0]}, but not in CHECKS")
        failed = True
    for name in names:
        check = CHECKS[name]
        if name not in blocks:
            print(f"FAIL {name}: no block with check={name} in the book")
            failed = True
            continue
        if "needs" in check and subprocess.run(
                ["bash", "-c", check["needs"]],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL).returncode != 0:
            print(f"skip {name}: `{check['needs']}` doesn't work here")
            if os.environ.get("CI"):
                failed = True
            continue
        file, text = blocks[name]
        subs = check.get("subs", [])
        output = run(name, check, blocks)
        book = [line for line in normalize(text, subs)
                if not line.startswith("(gdb)")]
        actual = normalize(output, subs)
        if check.get("joined"):
            # A message that the book splits to fit the page.
            book, actual = [" ".join(book)], [" ".join(actual)]
            check = dict(check, partial=True)
        subset = check.get("subset", False) or "gdb" in check \
            or any(line == "..." or " ... " in line for line in book)
        book = [line for line in book if line != "..."]
        reason = compare(book, actual, subset, check.get("partial", False),
                         check.get("optional", []))
        if reason:
            print(f"FAIL {name} ({file}):\n  " + reason.replace("\n", "\n  "))
            print("  output:\n    " + "\n    ".join(actual))
            failed = True
        else:
            print(f"ok   {name}")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
