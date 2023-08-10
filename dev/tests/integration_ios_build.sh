#!/usr/bin/env /bin/sh

output="../build/ios_integ"
product="build/ios_integ/Build/Products"
dev_target="15.7"


echo "Building the integration tests for iOS 🍏"
patrol build ios --target integration_test/main_test.dart --release --dart-define="ENV=test"

pushd $product
mv Runner_iphoneos*-arm64.xctestrun "Runner_iphoneos$dev_target-arm64.xctestrun"
zip -r "ios_tests.zip" "Release-iphoneos" "Runner_iphoneos$dev_target-arm64.xctestrun"
popd
