<?php

// A command-line progam that runs the dropbox_content_hasher tests.

require('strict.php');
require('DropboxContentHasher.php');

/**
 * A simple implementation, used solely to test the more complicated one.
 */
function referenceHasher($input, $length) {
    $offset = 0;
    $remaining = $length;

    $overallHasher = hash_init('sha256');

    while ($remaining > 0) {
        $partSize = min(DropboxContentHasher::BLOCK_SIZE, $remaining);
        $blockHasher = hash_init('sha256');
        hash_update($blockHasher, substr($input, $offset, $partSize));
        $blockDigest = hash_final($blockHasher, true);
        hash_update($overallHasher, $blockDigest);

        $remaining -= $partSize;
        $offset += $partSize;
    }

    return hash_final($overallHasher);
}

function check($data, $chunkSizes) {
    print("checking " . json_encode($chunkSizes) . "\n");

    $hasher = new DropboxContentHasher();

    $pos = 0;
    foreach ($chunkSizes as $chunkSize) {
        $chunk = substr($data, $pos, $chunkSize);
        $pos += $chunkSize;

        $hasher->update($chunk);
    }

    $result = bin2hex($hasher->digest());
    $reference = referenceHasher($data, array_sum($chunkSizes));

    $passed = ($result === $reference);
    if (!$passed) {
        print("- FAILED: " . json_encode($reference) . ", " . json_encode($result) . "\n");
    }
    return $passed;
}

function main($argc, $argv) {
    if ($argc !== 1) {
        fwrite(STDERR, "No arguments expected; got " . ($argc-1) . ".\n");
        exit(1);
    }

    $B = DropboxContentHasher::BLOCK_SIZE;

    $tests = [
        [0],
        [100],
        [100, 10],
        [$B-1],
        [$B],
        [$B+1],

        [$B-2, 1],
        [$B-2, 2],
        [$B-2, 3],

        [$B-2, $B+1],
        [$B-2, $B+2],
        [$B-2, $B+3],

        [5, 5, 5],
        [5, 5, 5, $B],
        [5, 5, 5, 3*$B],
        [5, 5, 5, 3*$B, 5, 5, 5, 3*$B],
    ];

    $longestLength = 0;
    foreach ($tests as $test) {
        $longestLength = max($longestLength, array_sum($test));
    }

    print("generating random data\n");
    $data = openssl_random_pseudo_bytes($longestLength);

    foreach ($tests as $test) {
        $passed = check($data, $test);
        if (!$passed) {
            exit(2);
        }
    }

    print("all passed\n");
}

main($argc, $argv);
