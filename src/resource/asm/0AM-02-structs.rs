// PURPOSE:
//     Show how the System V convention passes and
//     returns structures: `rustc --emit asm` shows
//     the code of `swap_pair` and `rotate_triple`.

// 16 bytes: travels in two registers.
#[repr(C)]
pub struct Pair {
    a: i64,
    b: i64,
}

// 24 bytes: travels in memory.
#[repr(C)]
pub struct Triple {
    a: i64,
    b: i64,
    c: i64,
}

#[unsafe(no_mangle)]
pub extern "C" fn swap_pair(p: Pair) -> Pair {
    Pair { a: p.b, b: p.a }
}

#[unsafe(no_mangle)]
pub extern "C" fn rotate_triple(t: Triple) -> Triple {
    Triple { a: t.b, b: t.c, c: t.a }
}

fn main() {
    let p = swap_pair(Pair { a: 1, b: 2 });
    println!("swap_pair: {} {}", p.a, p.b);
    let t = rotate_triple(Triple { a: 1, b: 2, c: 3 });
    println!("rotate_triple: {} {} {}", t.a, t.b, t.c);
}
