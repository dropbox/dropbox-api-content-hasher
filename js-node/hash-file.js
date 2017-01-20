"use strict";

// A command-line program that computes the Dropbox-Content-Hash of the given file.

const fs = require('fs');
const dch = require('./dropbox-content-hasher');

function main() {
  const args = process.argv.slice(2);

  if (args.length != 1) {
    console.error("Expecting exactly one argument; got " + args.length + ".");
    process.exit(1);
  }

  const fn = args[0];

  const hasher = dch.create();
  const f = fs.createReadStream(fn);
  f.on('data', function(buf) {
    hasher.update(buf);
  });
  f.on('end', function(err) {
    const hexDigest = hasher.digest('hex');
    console.log(hexDigest);
  });
  f.on('error', function(err) {
    console.error("Error reading from file: " + err);
    process.exit(1);
  });
}

main();
