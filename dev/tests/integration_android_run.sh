#!/usr/bin/env /bin/sh

committed_files=$(git show --pretty="" --name-only)
if [ -z $(echo "$committed_files" | grep -e "^build\/app\/outputs\/apk\/androidTest\/debug\/app-debug-androidTest\.apk$") ]; then
  echo "Last integration test build not found. Building...";

  dev/tests/integration_android_build.sh
fi

gcloud firebase test android run --type instrumentation \
 --app build/app/outputs/apk/debug/app-debug.apk \
 --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk \
 --timeout 1m \
 --device model=panther,version=33,locale=es,orientation=portrait \
 --results-bucket=gs://gmadrid-natacion-f5fcd.appspot.com \
 --results-dir=tests/firebase