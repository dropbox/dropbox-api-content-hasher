import java.nio.ByteBuffer;
import java.security.MessageDigest;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Random;

/**
 * A command-line tool that runs the DropboxContentHasher tests.
 */
public class RunTests
{
    /**
     * A simple implementation, used solely to test the more complicated one.
     */
    public static byte[] referenceHasher(byte[] input, int length)
    {
        int offset = 0;
        int remaining = length;

        MessageDigest overallHasher = DropboxContentHasher.newSha256Hasher();
        MessageDigest blockHasher = DropboxContentHasher.newSha256Hasher();

        while (remaining > 0) {
            int partSize = Math.min(DropboxContentHasher.BLOCK_SIZE, remaining);
            blockHasher.update(input, offset, partSize);
            byte[] d = blockHasher.digest();
            overallHasher.update(d);

            remaining -= partSize;
            offset += partSize;
        }

        return overallHasher.digest();
    }

    public static boolean check(byte[] data, int[] chunkLengths)
    {
        System.out.println("checking " + Arrays.toString(chunkLengths));

        MessageDigest byteArrayHasher = new DropboxContentHasher();
        MessageDigest byteBufferHasher = new DropboxContentHasher();
        MessageDigest byteHasher = new DropboxContentHasher();

        ArrayList<MessageDigest> clones = new ArrayList<MessageDigest>();

        int totalLength = 0;
        for (int chunkLength : chunkLengths) {
            totalLength += chunkLength;
        }

        int offset = 0;
        for (int chunkLength : chunkLengths) {
            clones.add(clone(byteArrayHasher));

            byteArrayHasher.update(data, offset, chunkLength);
            byteBufferHasher.update(ByteBuffer.wrap(data, offset, chunkLength));
            for (int i = 0; i < chunkLength; i++) {
                byteHasher.update(data[offset+i]);
            }

            for (MessageDigest clone : clones) {
                clone.update(data, offset, chunkLength);
            }

            offset += chunkLength;
        }

        ArrayList<MessageDigest> allDigests = new ArrayList<MessageDigest>();
        allDigests.add(byteArrayHasher);
        allDigests.add(byteBufferHasher);
        allDigests.add(byteHasher);
        allDigests.addAll(clones);

        String reference = hex(referenceHasher(data, totalLength));
        boolean passed = true;

        ArrayList<String> results = new ArrayList<String>();
        for (MessageDigest digest : allDigests) {
            String result = hex(digest.digest());
            results.add(result);
            if (!result.equals(reference)) {
                passed = false;
            }
        }

        if (!passed) {
            System.out.println("- FAILED: " + reference + ", " + results);
        }

        return passed;
    }

    public static void main(String[] args)
    {
        if (args.length > 0) {
            System.err.println("No arguments expected; got " + args.length + ".");
            System.exit(1); return;
        }

        int B = DropboxContentHasher.BLOCK_SIZE;

        int[][] tests = {
            {0},
            {100},
            {100, 10},
            {B-1},
            {B},
            {B+1},

            {B-2, 1},
            {B-2, 2},
            {B-2, 3},

            {B-2, B+1},
            {B-2, B+2},
            {B-2, B+3},

            {5, 5, 5},
            {5, 5, 5, B},
            {5, 5, 5, 3*B},
            {5, 5, 5, 3*B, 5, 5, 5, 3*B},
        };

        int longestLength = 0;
        for (int[] test : tests) {
            longestLength = Math.max(longestLength, sum(test));
        }

        System.out.println("generating random data");
        byte[] data = new byte[longestLength];
        new Random(0).nextBytes(data);

        for (int[] test : tests) {
            boolean passed = check(data, test);
            if (!passed) {
                System.exit(1); return;
            }
        }

        System.out.println("all passed");
    }

    private static int sum(int[] a)
    {
        int sum = 0;
        for (int i : a) {
            sum += i;
        }
        return sum;
    }

    public static MessageDigest clone(MessageDigest v)
    {
        try {
            return (MessageDigest) v.clone();
        } catch (CloneNotSupportedException ex) {
            throw new AssertionError("Couldn't clone()", ex);
        }
    }

    static final char[] HEX_DIGITS = new char[]{
        '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
        'a', 'b', 'c', 'd', 'e', 'f'};

    public static String hex(byte[] data)
    {
        char[] buf = new char[2*data.length];
        int i = 0;
        for (byte b : data) {
            buf[i++] = HEX_DIGITS[(b & 0xf0) >>> 4];
            buf[i++] = HEX_DIGITS[b & 0x0f];
        }
        return new String(buf);
    }
}
