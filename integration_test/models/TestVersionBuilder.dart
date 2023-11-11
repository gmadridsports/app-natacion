import 'package:gmadrid_natacion/Context/Natacion/domain/app/Version.dart';

class TestVersionBuilder {
  int _versionMajor = 1;
  int _versionMinor = 0;
  int _versionPatch = 0;
  int _buildNumber = 1;

  TestVersionBuilder withMajor(int version) {
    _versionMajor = version;

    return this;
  }

  TestVersionBuilder withMinor(int version) {
    _versionMinor = version;

    return this;
  }

  TestVersionBuilder withPatch(int version) {
    _versionPatch = version;

    return this;
  }

  TestVersionBuilder withBuildNumber(int buildNumber) {
    _buildNumber = buildNumber;

    return this;
  }

  Version build() {
    return Version.from(
        "$_versionMajor.$_versionMinor.$_versionPatch+${_buildNumber.toString()}");
  }
}
