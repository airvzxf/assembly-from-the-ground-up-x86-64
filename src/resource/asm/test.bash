#!/usr/bin/env bash
# Run the example programs and the solutions of Appendix K, and compare
# their exit status, output and files with the values the book explains.
# Run make.bash first.
set -Eeuo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

FAILED=0
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

pass() { echo "ok   $1"; }
fail() { echo "FAIL $1"; FAILED=1; }

# expect <program> <exit status> [stdin]
expect() {
  local program="$1" expected="$2" input="${3:-}" status=0
  printf '%s' "${input}" | "./${program}-bin" >/dev/null 2>&1 \
    || status=$?
  if [[ "${status}" == "${expected}" ]]; then
    pass "${program}: status ${status}"
  else
    fail "${program}: expected status ${expected}, got ${status}"
  fi
}

# expect_output <name> <expected stdout> <command...>   (reads $INPUT)
expect_output() {
  local name="$1" expected="$2" actual
  shift 2
  actual="$(printf '%s' "${INPUT:-}" | "$@" 2>/dev/null)" || true
  if [[ "${actual}" == "${expected}" ]]; then
    pass "${name}: output"
  else
    fail "${name}: expected output '${expected}', got '${actual}'"
  fi
}

# expect_file <name> <file> <expected content>
expect_file() {
  if [[ "$(cat "$2" 2>/dev/null)" == "$3" ]]; then
    pass "$1: file $2"
  else
    fail "$1: unexpected content in $2"
  fi
}

# ----- Book examples -----
expect 003-01-exit 0
expect 003-02-maximum 222
expect 003-03-maximum-absolute 222
# The box "Absolute Addresses and PIE" (Chapter 3): the %rip-relative
# program also links and runs as PIE; the absolute one can't be linked.
if ld -pie --no-dynamic-linker -o "${TMP_DIR}/maximum-pie" \
     003-02-maximum.o 2>/dev/null; then
  expect_output "003-02-maximum (PIE)" 222 \
    sh -c "'${TMP_DIR}/maximum-pie'; echo \$?"
else
  fail "003-02-maximum (PIE): can't be linked as PIE"
fi
if ld -pie --no-dynamic-linker -o "${TMP_DIR}/absolute-pie" \
     003-03-maximum-absolute.o 2>"${TMP_DIR}/pie.err"; then
  fail "003-03-maximum-absolute (PIE): linked, but it shouldn't"
elif grep -q "R_X86_64_32S.*can not be used when making a PIE object" \
       "${TMP_DIR}/pie.err"; then
  pass "003-03-maximum-absolute (PIE): rejected by ld"
else
  fail "003-03-maximum-absolute (PIE): unexpected error"
fi
expect 004-01-power 33
expect 004-02-factorial 24

# ----- Chapter 3 -----
expect 0AK-03-01-exit-3 3
expect 0AK-03-02-minimum 3
expect 0AK-03-03-maximum-255 125
expect 0AK-03-04-maximum-end-address 222
expect 0AK-03-05-maximum-length 222
# Without `syscall` the CPU runs past the code: SIGSEGV is 128 + 11.
expect 0AK-03-06-exit-without-syscall 139

# ----- Chapter 4 -----
expect 0AK-04-01-square 144
expect 0AK-04-02-maximum-function 99
expect 0AK-04-03-factorial-loop 120
expect 0AK-04-04-power-stack 33

# ----- Chapter 5 -----
expect_output 005-00-hello-world "Hello, World!" ./005-00-hello-world-bin
expect 005-00-hello-world 0
# 005-01-toupper with a file bigger than its 500-byte buffer: its own
# source code, compared with the result of `tr`.
./005-01-toupper-bin 005-01-toupper.s "${TMP_DIR}/toupper.txt"
expect_file 005-01-toupper "${TMP_DIR}/toupper.txt" \
  "$(tr 'a-z' 'A-Z' < 005-01-toupper.s)"
INPUT="Hey, diddle 123!" expect_output 0AK-05-01-toupper-stdio \
  "HEY, DIDDLE 123!" ./0AK-05-01-toupper-stdio-bin
printf 'The cow jumped over the moon; the little dog laughed.\n' \
  > "${TMP_DIR}/in.txt"
./0AK-05-02-toupper-bss-bin "${TMP_DIR}/in.txt" "${TMP_DIR}/out.txt"
expect_file 0AK-05-02-toupper-bss "${TMP_DIR}/out.txt" \
  "THE COW JUMPED OVER THE MOON; THE LITTLE DOG LAUGHED."
(cd "${TMP_DIR}" && "${OLDPWD}/0AK-05-03-heynow-bin")
expect_file 0AK-05-03-heynow "${TMP_DIR}/heynow.txt" "Hey diddle diddle!"
INPUT="abc" expect_output 0AK-05-04-toupper-checked "ABC" \
  ./0AK-05-04-toupper-checked-bin
./0AK-05-04-toupper-checked-bin "${TMP_DIR}/in.txt" "${TMP_DIR}/out2.txt"
expect_file 0AK-05-04-toupper-checked "${TMP_DIR}/out2.txt" \
  "THE COW JUMPED OVER THE MOON; THE LITTLE DOG LAUGHED."
expect_output "0AK-05-04-toupper-checked (missing file)" \
  "Error: can't open input file" \
  sh -c "./0AK-05-04-toupper-checked-bin /no/such/file x 2>&1"
expect_output "0AK-05-04-toupper-checked (one argument)" \
  "Usage: toupper [input output]" \
  sh -c "./0AK-05-04-toupper-checked-bin only-one 2>&1"

# ----- Chapter 6 -----
(
  cd "${TMP_DIR}"
  A="${OLDPWD}"
  "${A}/006-01-write-records-bin"          # Creates test.dat.
  "${A}/0AK-06-01-write-records-bin"       # test-phone.dat.
  "${A}/0AK-06-02-write-30-records-bin"    # test30.dat.
)
# Ages of the three records in a record file, one per line.
ages() {
  local offset
  for offset in 320 648 976; do
    od -A n -t d8 -j "${offset}" -N 8 "$1" | tr -d ' '
  done
}
# The book programs: 3 records of 328 bytes, their first names, and
# the ages after 006-01-add-year and 007-01-add-year.
if [[ "$(stat -c %s "${TMP_DIR}/test.dat")" == 984 ]]; then
  pass "006-01-write-records: 3 records of 328 bytes"
else
  fail "006-01-write-records: wrong file size"
fi
INPUT="" expect_output 006-01-read-records \
  "$(printf 'Fredrick\nMarilyn\nDerrick')" \
  sh -c "cd '${TMP_DIR}' && '${PWD}/006-01-read-records-bin'"
for PROGRAM in 006-01-add-year 007-01-add-year; do
  (cd "${TMP_DIR}" && rm -f testout.dat && "${OLDPWD}/${PROGRAM}-bin")
  if [[ "$(ages "${TMP_DIR}/testout.dat" | paste -sd ' ')" \
        == "46 30 37" ]]; then
    pass "${PROGRAM}: ages 46 30 37"
  else
    fail "${PROGRAM}: wrong ages"
  fi
done
mkdir -p "${TMP_DIR}/empty"
STATUS=0
OUTPUT="$(cd "${TMP_DIR}/empty" && "${OLDPWD}/007-01-add-year-bin" 2>&1)" \
  || STATUS=$?
if [[ "${OUTPUT}" == "0001: Can't Open Input File." && "${STATUS}" == 1 ]]
then
  pass "007-01-add-year (missing file): message and status 1"
else
  fail "007-01-add-year (missing file): '${OUTPUT}', status ${STATUS}"
fi
INPUT="" expect_output 0AK-06-01-read-records \
  "$(printf 'Fredrick: 555-0100\nMarilyn: 555-0199')" \
  sh -c "cd '${TMP_DIR}' && '${PWD}/0AK-06-01-read-records-bin'"
if [[ "$(stat -c %s "${TMP_DIR}/test-phone.dat")" == 704 ]]; then
  pass "0AK-06-01-write-records: 2 records of 352 bytes"
else
  fail "0AK-06-01-write-records: wrong file size"
fi
if [[ "$(stat -c %s "${TMP_DIR}/test30.dat")" == 9840 ]]; then
  pass "0AK-06-02-write-30-records: 30 records of 328 bytes"
else
  fail "0AK-06-02-write-30-records: wrong file size"
fi
in_tmp() { (cd "${TMP_DIR}" && "${OLDPWD}/$1-bin"); }
status_in_tmp() {
  local status=0
  in_tmp "$1" >/dev/null 2>&1 || status=$?
  if [[ "${status}" == "$2" ]]; then pass "$1: status ${status} $3"
  else fail "$1: expected status $2, got ${status} $3"; fi
}
status_in_tmp 0AK-06-03-max-age 45 "(ages 45, 29, 36)"
status_in_tmp 0AK-06-04-min-age 29 "(ages 45, 29, 36)"
in_tmp 0AK-06-05-add-year-in-place
status_in_tmp 0AK-06-03-max-age 46 "(after add-year-in-place)"
status_in_tmp 0AK-06-04-min-age 30 "(after add-year-in-place)"
if [[ "$(stat -c %s "${TMP_DIR}/test.dat")" == 984 ]]; then
  pass "0AK-06-05-add-year-in-place: file size unchanged"
else
  fail "0AK-06-05-add-year-in-place: file size changed"
fi
INPUT="Mar" expect_output 0AK-06-07-find-records "Marilyn" \
  sh -c "cd '${TMP_DIR}' && '${PWD}/0AK-06-07-find-records-bin'"
INPUT="Fredrickson" expect_output "0AK-06-07-find-records (5 chars)" \
  "Fredrick" \
  sh -c "cd '${TMP_DIR}' && '${PWD}/0AK-06-07-find-records-bin'"
INPUT="Zed" expect_output "0AK-06-07-find-records (no match)" "" \
  sh -c "cd '${TMP_DIR}' && '${PWD}/0AK-06-07-find-records-bin'"

# ----- Chapter 7 -----
C7="${TMP_DIR}/c7"
mkdir -p "${C7}"
(cd "${C7}" && "${OLDPWD}/006-01-write-records-bin")
(cd "${C7}" && "${OLDPWD}/0AK-07-01-add-year-robust-bin")
if [[ "$(ages "${C7}/testout.dat" | paste -sd ' ')" == "46 30 37" ]]; then
  pass "0AK-07-01-add-year-robust: ages 46 30 37"
else
  fail "0AK-07-01-add-year-robust: wrong ages"
fi
mv "${C7}/test.dat" "${C7}/input.dat"
rm "${C7}/testout.dat"
MESSAGE="$(cd "${C7}" && "${OLDPWD}/0AK-07-01-add-year-robust-bin" \
  < input.dat 2>&1)"
if [[ "${MESSAGE}" == "Warning: can't open test.dat, reading STDIN" \
   && "$(ages "${C7}/testout.dat" | paste -sd ' ')" == "46 30 37" ]]; then
  pass "0AK-07-01-add-year-robust: recovery from STDIN"
else
  fail "0AK-07-01-add-year-robust: recovery from STDIN"
fi
head -c 100 "${C7}/input.dat" > "${C7}/test.dat"  # Damaged file.
expect_output "0AK-07-01-add-year-robust (damaged file)" \
  "0004: Incomplete Record." \
  sh -c "cd '${C7}' && '${PWD}/0AK-07-01-add-year-robust-bin' 2>&1"
rm "${C7}/testout.dat"
mkdir "${C7}/testout.dat"  # A directory can't be opened for writing.
expect_output "0AK-07-01-add-year-robust (output error)" \
  "0002: Can't Open Output File." \
  sh -c "cd '${C7}' && '${PWD}/0AK-07-01-add-year-robust-bin' 2>&1"

# ----- Chapter 8 -----
DYNAMIC_LINKER=/lib64/ld-linux-x86-64.so.2
expect_output 008-01-hello-world-nolib "hello world" \
  ./008-01-hello-world-nolib-bin
expect_output 008-01-hello-world-lib "hello world" \
  ./008-01-hello-world-lib-bin
# The program that uses the C library also links and runs as PIE.
if ld --fatal-warnings -pie -o "${TMP_DIR}/hello-pie" \
     008-01-hello-world-lib.o -l c -dynamic-linker "${DYNAMIC_LINKER}"
then
  expect_output "008-01-hello-world-lib (PIE)" "hello world" \
    "${TMP_DIR}/hello-pie"
else
  fail "008-01-hello-world-lib (PIE): can't be linked as PIE"
fi
expect_output 008-02-printf-example \
  "Hi! Jonathan is the person number #3." ./008-02-printf-example-bin
# Code with absolute addresses can't go in a shared library.
if ld -shared -o "${TMP_DIR}/absolute.so" 003-03-maximum-absolute.o \
     2>"${TMP_DIR}/shared.err"; then
  fail "003-03-maximum-absolute (shared): linked, but it shouldn't"
elif grep -q "R_X86_64_32S.*can not be used when making a shared object" \
       "${TMP_DIR}/shared.err"; then
  pass "003-03-maximum-absolute (shared): rejected by ld"
else
  fail "003-03-maximum-absolute (shared): unexpected error"
fi
# 008-03-write-records writes the same file as 006-01-write-records,
# with the functions of librecord.so.
C8="${TMP_DIR}/c8"
mkdir -p "${C8}"
(cd "${C8}" && "${OLDPWD}/006-01-write-records-bin" && mv test.dat ref.dat)
(cd "${C8}" && LD_LIBRARY_PATH="${OLDPWD}" \
   "${OLDPWD}/008-03-write-records-bin")
if cmp -s "${C8}/test.dat" "${C8}/ref.dat"; then
  pass "008-03-write-records: same test.dat as 006-01-write-records"
else
  fail "008-03-write-records: different test.dat"
fi
expect_output "008-03-write-records (without LD_LIBRARY_PATH)" \
  "librecord.so: cannot open shared object file" \
  sh -c "env -u LD_LIBRARY_PATH ./008-03-write-records-bin 2>&1 \
         | grep -o 'librecord.so: cannot open shared object file'"
LIBRARY_OUTPUT="$(printf '%s\n' 'count_chars("hello world") = 11' \
  'call_count() = 1' 'call_count() = 2' 'call_count() = 3')"
expect_output "008-05-use-library (Rust)" "${LIBRARY_OUTPUT}" \
  env LD_LIBRARY_PATH=. ./008-05-use-library-bin
expect_output "008-06-use-library.py (Python)" "${LIBRARY_OUTPUT}" \
  python3 008-06-use-library.py

expect_output 0AK-08-02-factorial-printf "The factorial of 5 is 120." \
  env LD_LIBRARY_PATH=. ./0AK-08-02-factorial-printf-bin
./0AK-08-03-toupper-libc-bin "${TMP_DIR}/in.txt" "${TMP_DIR}/out3.txt"
expect_file 0AK-08-03-toupper-libc "${TMP_DIR}/out3.txt" \
  "THE COW JUMPED OVER THE MOON; THE LITTLE DOG LAUGHED."
expect_output "0AK-08-03-toupper-libc (missing file)" \
  "Error: can't open the files" \
  sh -c "./0AK-08-03-toupper-libc-bin /no/such/file '${TMP_DIR}/x' 2>&1"
expect_output "0AK-08-03-toupper-libc (one argument)" \
  "Error: can't open the files" \
  sh -c "./0AK-08-03-toupper-libc-bin only-one 2>&1"
# Through a pipe, stdout is fully buffered and this `exit` doesn't flush
# it, so only the message remains: the text of printf is lost.
expect_output 0AK-08-04-exit-message "exit() called: bye!" \
  sh -c "LD_PRELOAD=./libexitmsg.so ./008-02-printf-example-bin 2>&1"
expect_output 0AK-08-05-factorial.py \
  "$(printf '%s\n' '5! = 120' '10! = 3628800' \
     '20! = 2432902008176640000' '21! = -4249290049419214848')" \
  python3 0AK-08-05-factorial.py

# ----- Chapter 9 -----
# The memory map shows the program, the heap that brk created, the page
# of mmap and the stack.
MAPS="$(./009-01-memory-layout-bin)"
for AREA in "009-01-memory-layout-bin" "[heap]" "[stack]"; do
  if grep -qF -- "${AREA}" <<< "${MAPS}"; then
    pass "009-01-memory-layout: ${AREA}"
  else
    fail "009-01-memory-layout: no ${AREA} in the map"
  fi
done
# The program code starts at 0x400000 (not PIE), and its code is the
# only executable part besides the vdso.
if grep -q '^00400000-' <<< "${MAPS}" \
   && [[ "$(grep -c ' r-xp .*009-01-memory-layout-bin$' <<< "${MAPS}")" \
         == 1 ]]; then
  pass "009-01-memory-layout: code at 0x400000, one r-xp area"
else
  fail "009-01-memory-layout: unexpected program areas"
fi
# The heap is exactly one page (4096 bytes) long.
HEAP="$(grep -F '[heap]' <<< "${MAPS}" | cut -d ' ' -f 1)"
if (( 0x${HEAP#*-} - 0x${HEAP%-*} == 4096 )); then
  pass "009-01-memory-layout: heap of one page"
else
  fail "009-01-memory-layout: heap ${HEAP} is not one page"
fi
# With ASLR, the stack moves from one run to the next.
STACK1="$(./009-01-memory-layout-bin | grep -F '[stack]')"
STACK2="$(./009-01-memory-layout-bin | grep -F '[stack]')"
if [[ "${STACK1}" != "${STACK2}" ]]; then
  pass "009-01-memory-layout: the stack moves (ASLR)"
else
  fail "009-01-memory-layout: the stack didn't move"
fi
INPUT="" expect_output 009-02-read-records \
  "$(printf 'Fredrick\nMarilyn\nDerrick')" \
  sh -c "cd '${C8}' && cp ref.dat test.dat && '${PWD}/009-02-read-records-bin'"
expect 0AK-09-02-alloc-test 0
# The book's manager reuses memory but doesn't split regions (4).
expect 0AK-09-02-alloc-test-book 4
expect 0AK-09-03-alloc-auto-init 42
# Without allocate_init, the book's allocate fails and returns 0.
expect 0AK-09-03-alloc-auto-init-book 255

# ----- Chapter 10 -----
expect_output 010-01-shift-bit "He likes dressy clothes." \
  ./010-01-shift-bit-bin
expect_output 010-02-conversion-program 824 ./010-02-conversion-program-bin
expect_output 010-03-floating-point \
  "$(printf '%s\n' '16777216 + 1 = 16777216.0 (float)' \
     '16777216 + 1 = 16777217.0 (double)' \
     '0.1 + 0.2 = 0.30000000000000004' '7 / 2 = 3.5, truncated to 3')" \
  ./010-03-floating-point-bin
expect_output 0AK-10-02-print-numbers \
  "$(printf '%s\n' 120 3628800 2432902008176640000 377 ff 11111111 73)" \
  ./0AK-10-02-print-numbers-bin
expect 0AK-10-03-is-negative 100
for CASE in "1234:1234" "-56:-56" "007:7" "0:0" "42abc:42" \
            "9223372036854775807:9223372036854775807" \
            "-9223372036854775808:-9223372036854775808"; do
  INPUT="${CASE%%:*}"$'\n' expect_output \
    "0AK-10-04-number2integer (${CASE%%:*})" "${CASE#*:}" \
    ./0AK-10-04-number2integer-bin
done
expect 0AK-10-05-likes 21
expect_output 0AK-10-06-celsius \
  "$(printf '%s\n' '-40.0 F = -40.0 C' '32.0 F = 0.0 C' \
     '98.6 F = 37.0 C' '212.0 F = 100.0 C')" \
  ./0AK-10-06-celsius-bin

# ----- Chapter 11 -----
expect_output 011-01-hello-world.rs "Hello World!" ./011-01-hello-world-bin
expect_output 011-01-hello-world.py "Hello World!" \
  python3 011-01-hello-world.py
expect 011-02-maximum 222
STATUS=0
python3 011-02-maximum.py || STATUS=$?
if [[ "${STATUS}" == 222 ]]; then pass "011-02-maximum.py: status 222"
else fail "011-02-maximum.py: expected status 222, got ${STATUS}"; fi
# The assembly language of `rustc --emit asm` defines `maximum`.
if rustc --edition 2024 -C opt-level=2 --emit asm \
     -o "${TMP_DIR}/maximum.s" 011-02-maximum.rs \
   && grep -q '^maximum:' "${TMP_DIR}/maximum.s"; then
  pass "011-02-maximum: rustc --emit asm"
else
  fail "011-02-maximum: rustc --emit asm"
fi
for PROGRAM in ./0AK-11-01-toupper-bin "python3 0AK-11-01-toupper.py"; do
  rm -f "${TMP_DIR}/upper.txt"
  ${PROGRAM} 005-01-toupper.s "${TMP_DIR}/upper.txt"
  expect_file "0AK-11-01-toupper (${PROGRAM})" "${TMP_DIR}/upper.txt" \
    "$(tr 'a-z' 'A-Z' < 005-01-toupper.s)"
  expect_output "0AK-11-01-toupper (${PROGRAM}, missing file)" 1 \
    sh -c "${PROGRAM} /no/such/file '${TMP_DIR}/x' 2>/dev/null; echo \$?"
done

# ----- Chapter 12 -----
expect 012-01-allocate-many 0

# ----- Appendix M -----
expect 0AM-01-sum8 36
expect_output 0AM-02-structs \
  "swap_pair: 2 1"$'\n'"rotate_triple: 2 3 1" ./0AM-02-structs-bin

# ----- Appendix O -----
expect_output 0AO-02-strlen-test "errors: 0" \
  python3 0AO-02-strlen-test.py

# ----- Appendix A -----
# Run the GTK 4 example in a virtual X server: click the button, answer
# No (Escape: it keeps running), click again and answer Yes (Return: it
# ends with status 0). Each step waits for the window it needs instead
# of a fixed time: the first GTK start in a new container compiles the
# Mesa shaders (empty ~/.cache) and can take several seconds to show
# the dialog.
gui_test() {
  local name="$1" status=0
  shift
  "$@" 2>"${TMP_DIR}/gui.err" &
  GUI_PID=$!
  if wait_for 30 gui_window_visible \
     && gui_answer Escape && wait_for 10 gui_dialog_closed \
     && kill -0 "${GUI_PID}" \
     && gui_answer Return && wait_for 10 gui_exited; then
    wait "${GUI_PID}" || status=$?
    if [[ "${status}" == 0 ]] && ! grep -q CRITICAL "${TMP_DIR}/gui.err"
    then
      pass "${name}: No, then Yes, status 0"
      return
    fi
  fi
  kill "${GUI_PID}" 2>/dev/null || true
  wait "${GUI_PID}" 2>/dev/null || true
  fail "${name}: the dialog didn't work"
}
# wait_for <seconds> <command...>: run the command every 0.1 s until it
# succeeds; return 1 if it still fails after that many seconds.
wait_for() {
  local tries=$(($1 * 10))
  shift
  until "$@"; do
    ((--tries > 0)) || return 1
    sleep 0.1
  done
}
# gui_answer <key>: click in the middle of the window, on the button,
# wait until the dialog has the keyboard focus and press the key.
gui_answer() {
  # shellcheck disable=SC2034 # SCREEN and WINDOW: set by --shell
  local geometry X Y WIDTH HEIGHT SCREEN WINDOW
  geometry="$(xdotool getwindowgeometry --shell "${GUI_WINDOW}")" \
    || return 1
  eval "${geometry}"
  xdotool mousemove $((X + WIDTH / 2)) $((Y + HEIGHT / 2)) click 1
  wait_for 30 gui_dialog_focused && xdotool key "$1"
}
gui_window_visible() {
  GUI_WINDOW="$(xdotool search --all --onlyvisible --pid "${GUI_PID}" \
                --name '^GTK Example Program$' 2>/dev/null | head -1)"
  [[ -n "${GUI_WINDOW}" ]]
}
# The dialog is a window of the same program, other than the main one.
gui_dialog_focused() {
  local focus
  focus="$(xdotool getwindowfocus 2>/dev/null)" \
    && [[ "${focus}" != "${GUI_WINDOW}" ]] \
    && [[ "$(xdotool getwindowpid "${focus}" 2>/dev/null)" \
          == "${GUI_PID}" ]]
}
# Without a window manager the focus goes to the root window, not back
# to the main window, when the dialog closes.
gui_dialog_closed() { ! gui_dialog_focused; }
gui_exited() { ! kill -0 "${GUI_PID}" 2>/dev/null; }
if command -v Xvfb >/dev/null && command -v xdotool >/dev/null; then
  Xvfb :97 -screen 0 1024x768x24 >/dev/null 2>&1 &
  XVFB_PID=$!
  trap 'kill "${XVFB_PID}" 2>/dev/null; rm -rf "${TMP_DIR}"' EXIT
  export DISPLAY=:97 GDK_BACKEND=x11
  if wait_for 10 xdotool getdisplaygeometry >/dev/null 2>&1; then
    gui_test 0AA-01-gtk-example ./0AA-01-gtk-example-bin
    gui_test 0AA-01-gtk-example.py python3 0AA-01-gtk-example.py
  else
    fail "0AA-01-gtk-example: Xvfb didn't start"
  fi
else
  fail "0AA-01-gtk-example: Xvfb and xdotool are needed"
fi

exit "${FAILED}"
