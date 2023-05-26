#!/usr/bin/env /bin/sh

dev_target="15.7"

committed_files=$(git show --pretty="" --name-only)
if [ -z $(echo "$committed_files" | grep -e "^build\/ios_integ\/Build\/Products\/ios_tests\.zip$") ]; then
  echo "Last integration test build not found. Building...";

  ./integration_ios_build.sh
fi

gcloud firebase test ios run --test "build/ios_integ/Build/Products/ios_tests.zip" \
  --device model=iphone13pro,version=$dev_target,locale=en_US,orientation=portrait \
  --xcode-version=14.3 \
  --timeout 3m \
  --results-bucket=gs://gmadrid-natacion-f5fcd.appspot.com \
  --results-dir=tests/firebase
