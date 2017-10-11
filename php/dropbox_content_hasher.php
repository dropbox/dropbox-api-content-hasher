<?php

function dropbox_hash_stream($stream, $chunksize = 1024)
{
    // Based on:
    // https://www.dropbox.com/developers/reference/content-hash
    // https://github.com/dropbox/dropbox-api-content-hasher/blob/master/python/dropbox_content_hasher.py

    // milky-way-nasa.jpg:
    // block 1: 4194304 bytes, 2a846fa617c3361fc117e1c5c1e1838c336b6a5cef982c1a2d9bdf68f2f1992a
    // block 2: 4194304 bytes, c68469027410ea393eba6551b9fa1e26db775f00eae70a0c3c129a0011a39cf9
    // block 3: 1322815 bytes, 7376192de020925ce6c5ef5a8a0405e931b0a9a8c75517aacd9ca24a8a56818b
    // --------
    // file     9711423 bytes, 485291fa0ee50c016982abbfa943957bcd231aae0492ccbaa22c58e3997b35e0

    $BLOCK_SIZE = 4 * 1024 * 1024;

    $streamhasher = hash_init('sha256');
    $blockhasher = hash_init('sha256');

    $current_block = 1;
    $current_blocksize = 0;
    while (!feof($stream)) {
        $max_bytes_to_read = min($chunksize, $BLOCK_SIZE - $current_blocksize);
        $chunk = fread($stream, $max_bytes_to_read);
        if (strlen($chunk) == 0) {
            // This stream was a multiple of $BLOCK_SIZE; this "block" is empty
            // and shouldn't be hashed.
            break;
        }
        hash_update($blockhasher, $chunk);
        $current_blocksize += $max_bytes_to_read;

        if ($current_blocksize == $BLOCK_SIZE) {
            $blockhash = hash_final($blockhasher, true);
            #print('block ' . $current_block . ': ' . bin2hex($blockhash) . "\n");
            hash_update($streamhasher, $blockhash);
            $blockhasher = hash_init('sha256');
            $current_block += 1;
            $current_blocksize = 0;
        }
    }

    if ($current_blocksize > 0) {
        $blockhash = hash_final($blockhasher, true);
        #print('block ' . $current_block . ': ' . bin2hex($blockhash) . "\n");
        hash_update($streamhasher, $blockhash);
    }

    $filehash = hash_final($streamhasher);
    return $filehash;
}

function dropbox_hash_file($path)
{
    $handle = fopen($path, 'r');
    $hash = dropbox_hash_stream($handle);
    fclose($handle);
    return $hash;
}

foreach ($argv as $arg) {
    print($arg . ":\t" . dropbox_hash_file($arg) . "\n");
}
