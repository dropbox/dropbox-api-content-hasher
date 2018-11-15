<?php

/**
 * Computes a hash using the same algorithm that the Dropbox API uses for the
 * the "content_hash" metadata field.
 * 
 * The `digest()` method returns a raw binary representation of the hash.  The
 * "content_hash" field in the Dropbox API is a hexadecimal-encoded version of
 * the digest.
 * 
 * <code>
 * $path = "some-file";
 * $hasher = new DropboxContentHasher();
 * $f = fopen($path, 'r');
 * try {
 *     $ok = @$hasher->updateStream($f);
 *     if (!$ok) {
 *         throw new Exception("Error reading from file: " . error_get_last());
 *     }
 * } finally {
 *     fclose($f);
 * }
 * print(bin2hex($hasher->digest())."\n");
 * </code>
 */
final class DropboxContentHasher {
    const BLOCK_SIZE = 4 * 1024 * 1024;

    private $overallHasher;
    private $blockHasher;
    private $blockPos;

    function __construct() {
        $this->overallHasher = hash_init('sha256');
        $this->blockHasher = hash_init('sha256');
        $this->blockPos = 0;
    }

    function update($data) {
        assert(is_string($data));

        if ($this->overallHasher === null) {
            throw new LogicException("Can't use this object anymore; you already called digest()");
        }

        $offset = 0;
        while ($offset < strlen($data)) {
            if ($this->blockPos === self::BLOCK_SIZE) {
                $blockDigest = hash_final($this->blockHasher, true);
                hash_update($this->overallHasher, $blockDigest);
                $this->blockHasher = hash_init('sha256');
                $this->blockPos = 0;
            }

            $spaceInBlock = self::BLOCK_SIZE - $this->blockPos;
            $inputPartEnd = min(strlen($data), $offset+$spaceInBlock);
            $inputPartLength = $inputPartEnd - $offset;
            hash_update($this->blockHasher, substr($data, $offset, $inputPartLength));

            $this->blockPos += $inputPartLength;
            $offset = $inputPartEnd;
        }
    }

    /**
     * Updates the hasher with the remaining contents of `$inStream` and returns
     * `true`.  Internally, this just reads the stream in chunks and calls `update()`
     * with each chunk.
     *
     * If there's an error reading from the `$inStream`, returns `false`.  You can
     * use `error_get_last()` to get details about what went wrong.
     */
    function updateStream($inStream, $readChunkSize = self::BLOCK_SIZE) {
        while (!feof($inStream)) {
            $data = fread($inStream, $readChunkSize);
            if ($data === false) {
                return false;
            }
            $this->update($data);
        }
        return true;
    }

    function digest() {
        if ($this->overallHasher === null) {
            throw new LogicException("Can't use this object anymore; you already called digest()");
        }

        if ($this->blockPos > 0) {
            $blockDigest = hash_final($this->blockHasher, true);
            hash_update($this->overallHasher, $blockDigest);
            $this->blockHasher = null;
        }
        $digest = hash_final($this->overallHasher, true);
        $this->overallHasher = null;
        return $digest;
    }

    function __clone() {
        if ($this->overallHasher === null) {
            throw new LogicException("Can't use this object anymore; you already called digest()");
        }

        $this->overallHasher = hash_copy($this->overallHasher);
        $this->blockHasher = hash_copy($this->blockHasher);
    }
}
