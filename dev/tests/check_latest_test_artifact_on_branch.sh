#!/usr/bin/env /bin/bash

if [[ ! -z "$CI" ]]; then
  BRANCH_NAME=${GITHUB_HEAD_REF:-$(git branch --show-current)}
  git pull origin ${BRANCH_NAME} || exit 1;
  git diff --word-diff=porcelain origin/${BRANCH_NAME}~1 origin/${BRANCH_NAME} -- dev/tests/artifact_build_timestamp.info  > /tmp/timestamp-diff.txt || exit 2;
else
  git diff --word-diff=porcelain HEAD~1 -- dev/tests/artifact_build_timestamp.info  > /tmp/timestamp-diff.txt || exit 2;
fi

new_timestamp=$(cat /tmp/timestamp-diff.txt | grep --extended-regexp "^\+[0-9]{19}")
old_timestamp=$(cat /tmp/timestamp-diff.txt | grep --extended-regexp "^-[0-9]{19}")
new_timestamp="${new_timestamp:1}"
old_timestamp="${old_timestamp:1}"

if [ -z "$new_timestamp" ] || [ -n "${new_timestamp//[0-9]}" ]; then
  echo "It looks we don't have the latest test artifact prebuilt: timestamp unchanged since the last commit"
  exit 1
fi

if [ -z "$old_timestamp" ] || [ -n "${old_timestamp//[0-9]}" ]; then
  old_timestamp="-1"
fi

if [ $new_timestamp -gt $old_timestamp ]; then
  echo "It looks we could have the latest test artifact on remote."
  exit 0
fi

echo "It looks we don't have the latest test artifact: timestamp older than the previous commit"
exit 1


