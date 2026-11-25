// PURPOSE:
//     The maximum program of Chapter 3 in Rust: find
//     the largest number of a list and return it as
//     the exit status code (222).
//
// See the assembly language that rustc generates:
//     rustc --edition 2024 -C opt-level=2 \
//       --emit asm 011-02-maximum.rs

const DATA_ITEMS: [i64; 8] =
    [3, 67, 34, 222, 45, 22, 11, 125];

// `no_mangle` keeps the name `maximum` in the
// assembly language (Rust adds a long suffix to the
// names of its functions), and `inline(never)` keeps
// the function separate from `main`.
#[unsafe(no_mangle)]
#[inline(never)]
pub fn maximum(items: &[i64]) -> i64 {
    let mut largest = items[0];
    for &item in &items[1..] {
        if item > largest {
            largest = item;
        }
    }
    largest
}

fn main() {
    let largest = maximum(&DATA_ITEMS);
    std::process::exit(largest as i32);
}
