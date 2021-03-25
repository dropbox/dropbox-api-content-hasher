#!/bin/bash
#  Computes a hash using the same algorithm that the Dropbox API uses for the
#  the "content_hash" metadata field.
if [ -f "$1" ]; then
   BlockCount=$((($(stat -c %s "$1") + 4194303) / 4194304))
   AllSha=""
   ThisBlock=0
   while [ $ThisBlock -lt $BlockCount ]; do
      ThisSHA=$(dd if="$1" bs=4194304 count=1 skip=$ThisBlock 2>/dev/null|sha256sum)
      for Each in {0..62..2}; do
         AllSha+="\x${ThisSHA:$Each:2}"
      done
      ((ThisBlock++))
   done
   Result=$(printf "$AllSha"|sha256sum)
   echo ${Result%% *}
else
   echo "Error.  '$1' does not appear to be a file."
fi
