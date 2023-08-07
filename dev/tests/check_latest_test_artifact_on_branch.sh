#!/usr/bin/env /bin/sh

git diff --word-diff=porcelain HEAD~1 dev/tests/artifact_files_latest_build.info  > /tmp/timestamp-diff.txt || exit 1;
new_timestamp=$(grep --extended-regexp "^\+[0-9]{19}" < /tmp/timestamp-diff.txt)
old_timestamp=$(grep --extended-regexp "^-[0-9]{19}" < /tmp/timestamp-diff.txt)
new_timestamp="${new_timestamp:1}"
old_timestamp="${old_timestamp:1}"

if [ -z "$new_timestamp" ] || [ -n "${new_timestamp//[0-9]}" ]; then
  echo "It looks we don't have the latest test artifact prebuilt"
  exit 1
fi

if [ -z "$old_timestamp" ] || [ -n "${old_timestamp//[0-9]}" ]; then
  old_timestamp="-1"
fi

if [ $new_timestamp -gt $old_timestamp ]; then
  echo "It looks we got the latest artifact"
  exit 0
fi

echo "It looks we don't have the latest test artifact"
exit 1


