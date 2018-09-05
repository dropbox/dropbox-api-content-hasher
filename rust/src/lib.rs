extern crate digest;
extern crate sha2;
pub extern crate hex;

use digest::{Digest,Input,FixedOutput};
use sha2::Sha256;
use digest::generic_array::GenericArray;
use digest::generic_array::typenum::{U64};

pub const BLOCK_SIZE: usize = 4 * 1024 * 1024;

/// Computes a hash using the same algorithm that the Dropbox API uses for the
/// the "content_hash" metadata field.
///
/// Implements the `digest::Digest` trait, whose `result()` function returns a
/// raw binary representation of the hash.  The "content_hash" field in the
/// Dropbox API is a hexadecimal-encoded version of this value.
///
/// Example:
///
/// ```
/// extern crate digest;
/// extern crate dropbox_content_hasher;
/// use dropbox_content_hasher::{DropboxContentHasher, hex};
/// use std::io::Read;
/// use digest::{Digest,Input,FixedOutput};
///
/// let mut hasher = DropboxContentHasher::new();
/// let mut buf: [u8; 4096] = [0; 4096];
/// let mut f = std::fs::File::open("src/lib.rs").unwrap();
/// loop {
///     let len = f.read(&mut buf).unwrap();
///     if len == 0 { break; }
///     hasher.input(&buf[..len])
/// }
/// drop(f);
///
/// let hex_hash = format!("{:x}", hasher.result());
/// println!("{}", hex_hash);
/// ```

#[derive(Clone)]
pub struct DropboxContentHasher {
    overall_hasher: Sha256,
    block_hasher: Sha256,
    block_pos: usize,
}

impl DropboxContentHasher {
    pub fn new() -> Self {
        DropboxContentHasher {
            overall_hasher: Sha256::new(),
            block_hasher: Sha256::new(),
            block_pos: 0,
        }
    }
}

impl Default for DropboxContentHasher {
    fn default() -> Self { Self::new() }
}

impl Input for DropboxContentHasher {
    fn process(&mut self, mut input: &[u8]) {
        while input.len() > 0 {
            if self.block_pos == BLOCK_SIZE {
                let block_hasher = self.block_hasher.clone();
                self.overall_hasher.input(block_hasher.result().as_slice());
                self.block_hasher = Sha256::new();
                self.block_pos = 0;
            }

            let space_in_block = BLOCK_SIZE - self.block_pos;
            let (head, rest) = input.split_at(::std::cmp::min(input.len(), space_in_block));
            self.block_hasher.input(head);

            self.block_pos += head.len();
            input = rest;
        }
    }
}

impl FixedOutput for DropboxContentHasher {
    type OutputSize = <Sha256 as FixedOutput>::OutputSize;

    fn fixed_result(mut self) -> GenericArray<u8, Self::OutputSize> {
        if self.block_pos > 0 {
            self.overall_hasher.input(self.block_hasher.result().as_slice());
        }
        self.overall_hasher.result()
    }
}

impl digest::BlockInput for DropboxContentHasher {
    type BlockSize = U64;
}
