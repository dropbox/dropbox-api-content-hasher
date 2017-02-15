//! A command-line tool that runs the `DropboxContentHasher` tests.

extern crate digest;
extern crate rand;
extern crate dropbox_content_hasher;
extern crate sha2;

use digest::Digest;
use std::io::Write as io_Write;
use rand::Rng;
use dropbox_content_hasher::{DropboxContentHasher, BLOCK_SIZE, hex};

fn main() {
    let mut args = std::env::args();
    args.next().unwrap();  // Remove name of binary.
    if args.len() != 0 {
        writeln!(&mut std::io::stderr(), "No arguments expected; got {}.", args.len()).unwrap();
        std::process::exit(1);
    }

    let b = BLOCK_SIZE;

    let tests: &[&[usize]] = &[
        &[0],
        &[100],
        &[100, 10],
        &[b-1],
        &[b],
        &[b+1],

        &[b-2, 1],
        &[b-2, 2],
        &[b-2, 3],

        &[b-2, b+1],
        &[b-2, b+2],
        &[b-2, b+3],

        &[5, 5, 5],
        &[5, 5, 5, b],
        &[5, 5, 5, 3*b],
        &[5, 5, 5, 3*b, 5, 5, 5, 3*b],
    ];

    let longest_length = tests.iter().fold(0, |m, x| std::cmp::max(m, x.iter().sum()));

    println!("generating random data");
    let mut data: Box<[u8]> = vec![0; longest_length].into_boxed_slice();
    rand::ChaChaRng::new_unseeded().fill_bytes(data.as_mut());

    for &test in tests {
        let passed = check(data.as_ref(), test);
        if !passed {
            std::process::exit(2);
        }
    }
    println!("all passed");
}

fn reference_hasher(data: &[u8]) -> String {
    let mut overall_hasher = sha2::Sha256::new();
    for chunk in data.chunks(BLOCK_SIZE) {
        let mut block_hasher = sha2::Sha256::new();
        block_hasher.input(chunk);
        overall_hasher.input(block_hasher.result().as_slice());
    }
    hex(overall_hasher.result().as_slice())
}

fn check(data: &[u8], chunk_sizes: &[usize]) -> bool {
    println!("checking {:?}", chunk_sizes);

    let mut hasher = DropboxContentHasher::new();

    let mut input = data;
    let mut total_length = 0;
    for chunk_size in chunk_sizes.iter().cloned() {
        let (chunk, rest) = input.split_at(chunk_size);
        input = rest;
        hasher.input(chunk);
        total_length += chunk_size;
    }

    let result = hex(hasher.result().as_slice());
    let reference = reference_hasher(data.split_at(total_length).0);

    let passed = result == reference;
    if !passed {
        println!("- FAILED: {:?}, {:?}", reference, result)
    }
    passed
}
