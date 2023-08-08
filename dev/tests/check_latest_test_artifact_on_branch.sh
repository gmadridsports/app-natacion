#!/usr/bin/env /bin/bash

BRANCH_NAME=${GITHUB_HEAD_REF:-$(git branch --show-current)}
git diff --word-diff=porcelain ${BRANCH_NAME}~1 dev/tests/artifact_build_timestamp.info  > /tmp/timestamp-diff.txt || exit 1;
cat /tmp/timestamp-diff.txt;
new_timestamp=$(cat /tmp/timestamp-diff.txt | grep --extended-regexp "^\+[0-9]{19}")
old_timestamp=$(cat /tmp/timestamp-diff.txt | grep --extended-regexp "^-[0-9]{19}")
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


