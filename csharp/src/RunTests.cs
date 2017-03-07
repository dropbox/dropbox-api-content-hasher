using System;
using System.Security.Cryptography;

/// <summary>
/// A command-line tool that runs the DropboxContentHasher tests.
/// </summary>
public class RunTests
{
    public static void SubMain(String[] args)
    {
        if (args.Length > 0) {
            Console.WriteLine("The run-tests sub-command expects zero arguments; got " + args.Length + ".");
            Environment.Exit(1); return;
        }

        int B = DropboxContentHasher.BLOCK_SIZE;

        int[][] tests = {
            //new[] {0},
            //new[] {100},
            //new[] {100, 10},
            //new[] {B-1},
            //new[] {B},
            new[] {B+1},

            new[] {B-2, 1},
            new[] {B-2, 2},
            new[] {B-2, 3},

            new[] {B-2, B+1},
            new[] {B-2, B+2},
            new[] {B-2, B+3},

            new[] {5, 5, 5},
            new[] {5, 5, 5, B},
            new[] {5, 5, 5, 3*B},
            new[] {5, 5, 5, 3*B, 5, 5, 5, 3*B},
        };

        int longestLength = 0;
        foreach (var test in tests) {
            longestLength = Math.Max(longestLength, Sum(test));
        }

        Console.WriteLine("generating random data");
        byte[] data = new byte[longestLength];
        new Random(0).NextBytes(data);

        foreach (var test in tests) {
            bool passed = Check(data, test);
            if (!passed) {
                Environment.Exit(1); return;
            }
        }

        Console.WriteLine("all passed");
    }


    /// <summary>
    /// A simple implementation, used solely to test the more complicated one.
    /// </summary>
    public static byte[] ReferenceHasher(byte[] input, int length)
    {
        int offset = 0;
        int remaining = length;

        var overallHasher = SHA256.Create();
        var blockHasher = SHA256.Create();

        while (remaining > 0) {
            int partSize = Math.Min(DropboxContentHasher.BLOCK_SIZE, remaining);
            blockHasher.TransformFinalBlock((byte[])input.Clone(), offset, partSize);
            byte[] d = blockHasher.Hash;
            blockHasher.Initialize();
            overallHasher.TransformBlock(d, 0, d.Length, d, 0);

            remaining -= partSize;
            offset += partSize;
        }

        overallHasher.TransformFinalBlock(Array.Empty<byte>(), 0, 0);
        return overallHasher.Hash;
    }

    public static bool Check(byte[] data, int[] chunkLengths)
    {
        Console.WriteLine("checking [{0}]", string.Join(", ", chunkLengths));

        var hasher = new DropboxContentHasher();
        int totalLength = Sum(chunkLengths);

        int offset = 0;
        foreach (int chunkLength in chunkLengths) {
            hasher.TransformBlock(data, offset, chunkLength, data, offset);
            offset += chunkLength;
        }

        hasher.TransformFinalBlock(Array.Empty<byte>(), 0, 0);
        var result = DropboxContentHasher.ToHex(hasher.Hash);
        var reference = DropboxContentHasher.ToHex(ReferenceHasher(data, totalLength));

        bool passed = (result == reference);
        if (!passed) {
            Console.WriteLine("- FAILED: " + reference + ", " + result);
        }
        return passed;
    }

    private static int Sum(int[] a)
    {
        int sum = 0;
        foreach (int i in a) {
            sum += i;
        }
        return sum;
    }
}
