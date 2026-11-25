// PURPOSE:
//     Call the assembly functions `count_chars` and
//     `call_count` of the shared library `libbook.so`
//     from Rust.
//
// Build and run:
//     rustc --edition 2024 -L . -l book \
//       -o 008-05-use-library 008-05-use-library.rs
//     LD_LIBRARY_PATH=. ./008-05-use-library

use std::ffi::c_char;

// The functions follow the system calling convention,
// which Rust calls "C". The compiler can't check what
// is in the library, so calling them is `unsafe`.
unsafe extern "C" {
    fn count_chars(string: *const c_char) -> u64;
    fn call_count() -> u64;
}

fn main() {
    // A C string literal ends with a null byte.
    let text = c"hello world";
    let length = unsafe { count_chars(text.as_ptr()) };
    println!("count_chars({text:?}) = {length}");

    for _ in 0..3 {
        let calls = unsafe { call_count() };
        println!("call_count() = {calls}");
    }
}
