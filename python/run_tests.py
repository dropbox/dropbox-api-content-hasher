from __future__ import absolute_import, division, print_function, unicode_literals

# A command-line progam that runs the dropbox_content_hasher tests.

import hashlib
import os
import six
import sys

from dropbox_content_hasher import DropboxContentHasher, StreamHasher

def reference_hasher(data):
    """
    A simpler implementation, used solely to test the more complicated one.
    """
    assert isinstance(data, six.binary_type), (
        "Expecting a byte string, got {!r}".format(data))
    block_hashes = (hashlib.sha256(data[i:i+DropboxContentHasher.BLOCK_SIZE]).digest()
                    for i in six.moves.xrange(0, len(data), DropboxContentHasher.BLOCK_SIZE))
    return hashlib.sha256(b''.join(block_hashes)).hexdigest()

def check(data, chunk_sizes):
    print("checking {!r}".format(chunk_sizes))
    hashers = [DropboxContentHasher()]

    read_hasher = DropboxContentHasher()
    read_stream = StreamHasher(six.BytesIO(data), read_hasher)

    write_hasher = DropboxContentHasher()
    write_target = six.BytesIO()
    write_stream = StreamHasher(write_target, write_hasher)

    pos = 0
    for chunk_size in chunk_sizes:
        chunk = data[pos:pos+chunk_size]
        pos += chunk_size

        hashers.append(hashers[0].copy())
        for hasher in hashers:
            hasher.update(chunk)
        
        write_stream.write(chunk)
        read_chunk = read_stream.read(len(chunk))
        assert read_chunk == chunk

    written = write_target.getvalue()
    assert written == data, (len(written), len(data))

    results = [hasher.hexdigest() for hasher in hashers + [read_hasher, write_hasher]]
    reference = reference_hasher(data)

    passed = all(result == reference for result in results)
    if not passed:
        print("- FAILED: {!r}, {!r}".format(reference, results))
    return passed

def main():
    args = sys.argv[1:]
    assert len(args) == 0, "No arguments expected; got {!r}.".format(args)

    B = DropboxContentHasher.BLOCK_SIZE

    tests = [
        [0],
        [100],
        [100, 10],
        [B-1],
        [B],
        [B+1],

        [B-2, 1],
        [B-2, 2],
        [B-2, 3],

        [B-2, B+1],
        [B-2, B+2],
        [B-2, B+3],

        [5, 5, 5],
        [5, 5, 5, B],
        [5, 5, 5, 3*B],
        [5, 5, 5, 3*B, 5, 5, 5, 3*B],
    ]

    longest_length = 0
    for test in tests:
        longest_length = max(longest_length, sum(test))

    print("generating random data")
    data = os.urandom(longest_length)

    for test in tests:
        passed = check(data[:sum(test)], test)
        if not passed:
            sys.exit(2)

    print("all passed")

if __name__ == '__main__':
    main()
