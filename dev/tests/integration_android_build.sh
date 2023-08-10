#!/usr/bin/env /bin/sh

flutter build apk --config-only && patrol build android --target integration_test/main_test.dart --dart-define="ENV=test" --verbose