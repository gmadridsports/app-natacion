#!/usr/bin/env /bin/bash

echo "Running the integration iOS tests 🧪"

echo "Checking if test build artifacts have been pulled properly..."

must_build=

for artifact_filepaths in "dev/tests/artifact_files_ios.txt"; do
  for local_filepath in $(<${artifact_filepaths}); do
    if [ ! -f ${local_filepath} ]; then
      echo "Integration test artifact not found. Probably the pull did not found any artifact on remote 🤔. Check above. Building...";

      must_build=1
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
    SUPABASE_ADMIN_TEST_PASSWORD=${SUPABASE_ADMIN_TEST_PASSWORD} dev/tests/integration_ios_build.sh
fi


dev_target="15.7"

gcloud firebase test ios run --test "build/ios_integ/Build/Products/ios_tests.zip" \
  --device model=iphone13pro,version=$dev_target,locale=en_US,orientation=portrait \
  --xcode-version=14.3 \
  --timeout 3m \
  --results-bucket=gs://gmadrid-natacion-f5fcd.appspot.com \
  --results-dir=tests/firebase
