// PURPOSE:
//     Solution to Chapter 11, "Use the Concepts":
//     `005-01-toupper` in Rust. It converts a file
//     to uppercase.
//
// USAGE:
//     ./0AK-11-01-toupper input.txt output.txt

use std::{env, fs, process};

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() != 3 {
        eprintln!("Usage: toupper input output");
        process::exit(1);
    }
    // read() and write() open, read or write, and
    // close the files, with all the buffering and
    // error checks.
    let text = match fs::read(&args[1]) {
        Ok(bytes) => bytes,
        Err(error) => {
            eprintln!("Error: {}: {error}", args[1]);
            process::exit(1);
        }
    };
    let upper = text.to_ascii_uppercase();
    if let Err(error) = fs::write(&args[2], upper) {
        eprintln!("Error: {}: {error}", args[2]);
        process::exit(1);
    }
}
