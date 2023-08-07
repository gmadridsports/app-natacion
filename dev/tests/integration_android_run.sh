#!/usr/bin/env /bin/sh

echo "Checking if pulled test build artifacts are the latest ones..."
artifact_check_result_output=$(dev/tests/check_latest_test_artifact_on_branch.sh)
artifact_check_result="${?}"

echo $artifact_check_result_output;

if [ $artifact_check_result -eq 1 ]; then
  echo "Building...";

  dev/tests/integration_ios_build.sh
fi

echo "Checking if test build artifact are here..."
if [ ! -f "build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk" ]; then
  echo "Integration test artifact not found. Building...";

  dev/tests/integration_ios_build.sh
fi

echo "Running the integration tests on firebase..."
gcloud firebase test android run --type instrumentation \
 --app build/app/outputs/apk/debug/app-debug.apk \
 --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk \
 --timeout 1m \
 --device model=panther,version=33,locale=es,orientation=portrait \
 --results-bucket=gs://gmadrid-natacion-f5fcd.appspot.com \
 --results-dir=tests/firebase