using System;

/// <summary>
/// The entrypoint for both RunTests and HashFile.  Using a shared entrypoint
/// because I can't figure out how to build two executables in a single project.
/// </summary>
public class CLI
{
    public static void Main(string[] args)
    {
        if (args.Length == 0) {
            Console.WriteLine("Usage:");
            Console.WriteLine("    COMMAND run-tests");
            Console.WriteLine("    COMMAND hash-file <path>");
            return;
        }

        var sub = args[0];
        var subArgs = new string[args.Length-1];
        Array.Copy(args, 1, subArgs, 0, subArgs.Length);

        if (sub == "run-tests") {
            RunTests.SubMain(subArgs);
        } else if (sub == "hash-file") {
            HashFile.SubMain(subArgs);
        } else {
            Console.Error.WriteLine("Unknown sub-command: \"{0}\".", sub);
            Environment.Exit(1); return;
        }
    }
}
