#!/usr/bin/env /bin/sh

git diff --word-diff=porcelain HEAD~1 dev/tests/artifact_files_latest_build.info  > /tmp/timestamp-diff.txt

# check if HEAD~1 has a different timestamp


