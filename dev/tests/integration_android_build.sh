#!/usr/bin/env /bin/sh

echo "Building the integration tests for android 🤖"
flutter build apk --config-only && patrol build android --target integration_test/main_test.dart --dart-define="ENV=test"