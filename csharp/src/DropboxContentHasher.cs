using System;
using System.Security.Cryptography;

/// <summary>
/// Computes a hash using the same algorithm that the Dropbox API uses for the
/// the "content_hash" metadata field.
/// </summary>
///
/// <para>
/// The {@link #digest()} method returns a raw binary representation of the hash.
/// The "content_hash" field in the Dropbox API is a hexadecimal-encoded version
/// of the digest.
/// </para>
///
/// <example>
/// var hasher = new DropboxContentHasher();
/// byte[] buf = new byte[1024];
/// using (var file = File.OpenRead("some-file"))
/// {
///     while (true)
///     {
///         int n = file.Read(buf, 0, buf.Length);
///         if (n &lt;= 0) break;  // EOF
///         hasher.TransformBlock(buf, 0, n, buf, 0);
///     }
/// }
///
/// hasher.TransformFinalBlock(Array.Empty<byte>(), 0, 0);
/// string hexHash = DropboxContentHasher.ToHex(hasher.Hash);
/// Console.WriteLine(hexHash);
/// </example>
public class DropboxContentHasher : HashAlgorithm
{
    private SHA256 overallHasher;
    private SHA256 blockHasher;
    private int blockPos = 0;

    public const int BLOCK_SIZE = 4 * 1024 * 1024;

    public DropboxContentHasher() : this(SHA256.Create(), SHA256.Create(), 0) {}

    public DropboxContentHasher(SHA256 overallHasher, SHA256 blockHasher, int blockPos)
    {
        this.overallHasher = overallHasher;
        this.blockHasher = blockHasher;
        this.blockPos = blockPos;
    }

    public override int HashSize { get { return overallHasher.HashSize; } }

    protected override void HashCore(byte[] input, int offset, int len)
    {
        int inputEnd = offset + len;
        while (offset < inputEnd) {
            if (blockPos == BLOCK_SIZE) {
                FinishBlock();
            }

            int spaceInBlock = BLOCK_SIZE - this.blockPos;
            int inputPartEnd = Math.Min(inputEnd, offset+spaceInBlock);
            int inputPartLength = inputPartEnd - offset;
            blockHasher.TransformBlock(input, offset, inputPartLength, input, offset);

            blockPos += inputPartLength;
            offset += inputPartLength;
        }
    }

    protected override byte[] HashFinal()
    {
        if (blockPos > 0) {
            FinishBlock();
        }
        overallHasher.TransformFinalBlock(Array.Empty<byte>(), 0, 0);
        return overallHasher.Hash;
    }

    public override void Initialize()
    {
        blockHasher.Initialize();
        overallHasher.Initialize();
        blockPos = 0;
    }

    private void FinishBlock()
    {
        blockHasher.TransformFinalBlock(Array.Empty<byte>(), 0, 0);
        byte[] blockHash = blockHasher.Hash;
        blockHasher.Initialize();

        overallHasher.TransformBlock(blockHash, 0, blockHash.Length, blockHash, 0);
        blockPos = 0;
    }

    private const string HEX_DIGITS = "0123456789abcdef";

    /// <summary>
    /// A convenience method to convert a byte array into a hexadecimal string.
    /// </summary>
    public static string ToHex(byte[] data)
    {
        var r = new System.Text.StringBuilder();
        foreach (byte b in data) {
            r.Append(HEX_DIGITS[(b >> 4)]);
            r.Append(HEX_DIGITS[(b & 0xF)]);
        }
        return r.ToString();
    }
}