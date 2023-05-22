output="../build/ios_integ"
product="build/ios_integ/Build/Products"
dev_target="15.7"

patrol build ios --target integration_test/example_test.dart --release --verbose

pushd $product
mv "Runner_iphoneos16.4-arm64.xctestrun" "Runner_iphoneos$dev_target-arm64.xctestrun"
zip -r "ios_tests.zip" "Release-iphoneos" "Runner_iphoneos$dev_target-arm64.xctestrun"
popd

gcloud firebase test ios run --test "build/ios_integ/Build/Products/ios_tests.zip" \
  --device model=iphone13pro,version=$dev_target,locale=en_US,orientation=portrait \
  --xcode-version=14.3 \
  --timeout 3m \
  --results-bucket=gs://gmadrid-natacion-f5fcd.appspot.com \
  --results-dir=tests/firebase
