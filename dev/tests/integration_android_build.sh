#!/usr/bin/env /bin/bash

SUPABASE_ADMIN_TEST_PASSWORD=$(cat dev/tests/env/supabase-admin-test-test-password)

echo "Building the integration tests for android 🤖"
java --version
flutter build apk --config-only && patrol build android --target integration_test/main_test.dart --dart-define="ENV=test" --dart-define="SUPABASE_ADMIN_TEST_PASSWORD=${SUPABASE_ADMIN_TEST_PASSWORD}"