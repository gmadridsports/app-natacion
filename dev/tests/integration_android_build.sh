#!/usr/bin/env /bin/sh

patrol build android --target integration_test/main_test.dart --dart-define="ENV=test" --verbose
