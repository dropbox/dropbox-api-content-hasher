using System;
using System.IO;

/// <summary>
/// A command-line tool that computes the Dropbox-Content-Hash of the given file.
/// </summary>
public class HashFile
{
    public static void SubMain(string[] args)
    {
        if (args.Length != 1) {
            Console.Error.WriteLine("The hash-file sub-command expects exactly one argument, got " + args.Length + ".");
            Environment.Exit(1); return;
        }

        string fn = args[0];

        var hasher = new DropboxContentHasher();
        byte[] buf = new byte[1024];
        using (var file = File.OpenRead(fn))
        {
            while (true)
            {
                int n = file.Read(buf, 0, buf.Length);
                if (n <= 0) break;  // EOF
                hasher.TransformBlock(buf, 0, n, buf, 0);
            }
        }

        hasher.TransformFinalBlock(Array.Empty<byte>(), 0, 0);
        string hexHash = DropboxContentHasher.ToHex(hasher.Hash);
        Console.WriteLine(hexHash);

        byte[] all = File.ReadAllBytes(fn);
        Console.WriteLine(DropboxContentHasher.ToHex(RunTests.ReferenceHasher(all, all.Length)));
        hasher = new DropboxContentHasher();
        hasher.TransformBlock(all, 0, all.Length, all, 0);
        hasher.TransformFinalBlock(Array.Empty<byte>(), 0, 0);
        Console.WriteLine(DropboxContentHasher.ToHex(hasher.Hash));
    }
}
