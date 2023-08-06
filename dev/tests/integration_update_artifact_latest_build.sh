#!/usr/bin/env /bin/sh

echo "Updating the latest artifact build info..."
date +%s%N > dev/tests/artifact_files_latest_build.info
echo "Done."
