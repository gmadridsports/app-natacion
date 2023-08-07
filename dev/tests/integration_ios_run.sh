#!/usr/bin/env /bin/sh

dev_target="15.7"
echo "Checking if pulled test build artifacts are the latest ones..."
artifact_check_result_output=$(dev/tests/check_latest_test_artifact_on_branch.sh)
artifact_check_result="${?}"

echo $artifact_check_result_output;

if [ $artifact_check_result -eq 1 ]; then
  echo "Building...";

  dev/tests/integration_ios_build.sh
fi

echo "Checking if test build artifact are here..."
if [ ! -f "build/ios_integ/Build/Products/ios_tests.zip" ]; then
  echo "Integration test artifact not found. Building...";

  dev/tests/integration_ios_build.sh
fi

gcloud firebase test ios run --test "build/ios_integ/Build/Products/ios_tests.zip" \
  --device model=iphone13pro,version=$dev_target,locale=en_US,orientation=portrait \
  --xcode-version=14.3 \
  --timeout 3m \
  --results-bucket=gs://gmadrid-natacion-f5fcd.appspot.com \
  --results-dir=tests/firebase
