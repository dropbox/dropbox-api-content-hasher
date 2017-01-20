from __future__ import absolute_import, division, print_function, unicode_literals

# A command-line program that computes the Dropbox-Content-Hash of the given file.

import sys

from dropbox_content_hasher import DropboxContentHasher

def main():
    prog_name, args = sys.argv[0], sys.argv[1:]
    if len(args) != 1:
        sys.stderr.write("Expecting exactly one argument, got {}.\n".format(len(args)))
        sys.exit(1)

    fn = args[0]

    hasher = DropboxContentHasher()
    with open(fn, 'rb') as f:
        while True:
            chunk = f.read(1024)  # or whatever chunk size you want
            if len(chunk) == 0:
                break
            hasher.update(chunk)
    print(hasher.hexdigest())

if __name__ == '__main__':
    main()
