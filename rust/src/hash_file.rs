//! A command-line tool that computes the Dropbox-Content-Hash of the given file.

extern crate digest;
extern crate dropbox_content_hasher;

use std::io::Write as io_Write;
use std::io::Read as io_Read;
use digest::Digest;
use dropbox_content_hasher::DropboxContentHasher;

fn main() {
    let mut args = std::env::args();
    args.next().unwrap();  // Remove name of binary.
    if args.len() != 1 {
        writeln!(&mut std::io::stderr(), "Expecting exactly one argument, got {}.", args.len()).unwrap();
        std::process::exit(1);
    }

    let file_name = args.next().unwrap();

    let mut hasher = DropboxContentHasher::new();
    let mut buf: [u8; 4096] = [0; 4096];
    let mut f = std::fs::File::open(file_name).unwrap();
    loop {
        let len = f.read(&mut buf).unwrap();
        if len == 0 { break; }
        hasher.input(&buf[..len])
    }
    drop(f);

    let hex_hash = format!("{:x}", hasher.result());
    println!("{}", hex_hash);
}