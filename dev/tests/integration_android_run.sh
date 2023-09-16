#!/usr/bin/env /bin/bash

echo "Running the integration android tests 🧪"

echo "Checking if test build artifacts have been pulled properly..."

must_build=

for artifact_filepaths in "dev/tests/artifact_files_android.txt"; do
  for local_filepath in $(<${artifact_filepaths}); do
    if [ ! -f ${local_filepath} ]; then
      echo "Integration test artifact not found. Probably the pull did not found any artifact on remote 🤔. Check above. Building...";

      must_build=1;
    fi
  done
done

if [ -z "${must_build}" ]; then
  echo "Build artifacts are here. Checking if potential pulled test build artifacts are the latest ones we need..."
  artifact_check_result_output=$(dev/tests/check_latest_test_artifact_on_branch.sh)
  artifact_check_result="${?}"

  echo $artifact_check_result_output;

  if [ $artifact_check_result -eq 1 ]; then
    must_build=1;
  fi
fi

if [ -n "${must_build}" ]; then
    echo "${must_build}"
    dev/tests/integration_android_build.sh
fi

echo "Running the integration tests on firebase..."
gcloud firebase test android run --type instrumentation \
 --app build/app/outputs/apk/debug/app-debug.apk \
 --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk \
 --environment-variables clearPackageData=true \
 --use-orchestrator \
 --timeout 1m \
 --device model=panther,version=33,locale=es,orientation=portrait \
 --results-bucket=gs://gmadrid-natacion-f5fcd.appspot.com \
 --results-dir=tests/firebase