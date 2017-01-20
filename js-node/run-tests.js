"use strict";

// A command-line program that runs the dropbox-content-hasher tests.

const crypto = require('crypto');
const dch = require('./dropbox-content-hasher');

function referenceHasher(data) {
  const overallHasher = crypto.createHash('sha256');
  for (let pos = 0; pos < data.length; pos += dch.BLOCK_SIZE) {
    const chunk = data.slice(pos, pos+dch.BLOCK_SIZE);
    const blockHasher = crypto.createHash('sha256');
    blockHasher.update(chunk);
    overallHasher.update(blockHasher.digest());
  }
  return overallHasher.digest('hex');
}

function check(data, chunkSizes) {
  console.log("checking " + JSON.stringify(chunkSizes));

  const hasher = dch.create();

  let pos = 0;
  for (const chunkSize of chunkSizes) {
    const chunk = data.slice(pos, pos+chunkSize);
    pos += chunkSize;

    hasher.update(chunk);
  }

  const result = hasher.digest('hex');
  const reference = referenceHasher(data.slice(0, sum(chunkSizes)))

  const passed = (result === reference);
  if (!passed) {
    console.log("- FAILED: " + JSON.stringify(reference) + ", " + JSON.stringify(result));
  }
  return passed;
}

function sum(arr) {
  let r = 0;
  for (const n of arr) {
    r += n;
  }
  return r;
}

function main() {
  const args = process.argv.slice(2);
  if (args.length > 0) {
    console.error("No arguments expected; got " + args.length + ".");
    process.exit(1);
  }

  const B = dch.BLOCK_SIZE;

  const tests = [
    [0],
    [100],
    [100, 10],
    [B-1],
    [B],
    [B+1],

    [B-2, 1],
    [B-2, 2],
    [B-2, 3],

    [B-2, B+1],
    [B-2, B+2],
    [B-2, B+3],

    [5, 5, 5],
    [5, 5, 5, B],
    [5, 5, 5, 3*B],
    [5, 5, 5, 3*B, 5, 5, 5, 3*B],
  ];

  let longestLength = 0;
  for (const test of tests) {
    longestLength = Math.max(longestLength, sum(test));
  }

  console.log("generating random data");
  const data = crypto.randomBytes(longestLength);

  for (const test of tests) {
    const passed = check(data, test);
    if (!passed) {
      process.exit(2);
    }
  }
  console.log("all passed");
}

main();
