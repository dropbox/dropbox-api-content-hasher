<?php

// A command-line program that computes the Dropbox-Content-Hash of the given file.

require('strict.php');
require('DropboxContentHasher.php');

function main($argc, $argv) {
    if ($argc != 2) {
        fwrite(STDERR, "Expecting exactly one argument; got " . ($argc-1) . ".\n");
        exit(1);
    }

    $path = $argv[1];

    $hasher = new DropboxContentHasher();
    $f = fopen($path, 'r');
    try {
        $ok = @$hasher->updateStream($f);
        if (!$ok) {
            throw new Exception("Error reading from file: " . error_get_last());
        }
    } finally {
        fclose($f);
    }
    print(bin2hex($hasher->digest())."\n");
}

main($argc, $argv);
