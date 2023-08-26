#!/usr/bin/env /bin/sh

echo "Updating the latest artifact build info..."
date +%s%N > dev/tests/artifact_build_timestamp.info
uuidgen > dev/tests/artifact_build_uuid.info || cat /proc/sys/kernel/random/uuid || exit 1;
echo "Done."
