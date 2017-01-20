import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.security.MessageDigest;

/**
 * A command-line tool that computes the Dropbox-Content-Hash of the given file.
 */
public class HashFile
{
    public static void main(String[] args)
        throws IOException
    {
        if (args.length != 1) {
            System.err.println("Expecting exactly one argument, got " + args.length + ".");
            System.exit(1); return;
        }

        String fn = args[0];

        MessageDigest hasher = new DropboxContentHasher();
        byte[] buf = new byte[1024];
        InputStream in = new FileInputStream(fn);
        try {
            while (true) {
                int n = in.read(buf);
                if (n < 0) break;  // EOF
                hasher.update(buf, 0, n);
            }
        }
        finally {
            in.close();
        }

        System.out.println(RunTests.hex(hasher.digest()));
    }
}
