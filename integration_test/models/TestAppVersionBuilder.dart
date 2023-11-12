import 'package:gmadrid_natacion/Context/Natacion/domain/app/AppVersion.dart';
import 'package:gmadrid_natacion/Context/Natacion/domain/app/Version.dart';

import 'TestVersionBuilder.dart';

class TestAppVersionBuilder {
  Version currentAppVersion = TestVersionBuilder().build();
  Version remoteVersion = TestVersionBuilder().build();
  bool isCurrentAppVersion = true;
  String? url;

  withCurrentAppVersion(Version currentAppVersion, Version remoteVersion) {
    this.currentAppVersion = currentAppVersion;
    this.remoteVersion = remoteVersion;
    this.isCurrentAppVersion = true;

    return this;
  }

  withLatestRemoteAppVersion(Version latestRemoteVersion, String url) {
    isCurrentAppVersion = false;
    remoteVersion = latestRemoteVersion;
    this.url = url;

    return this;
  }

  AppVersion build() {
    if (isCurrentAppVersion) {
      return AppVersion.from(currentAppVersion, remoteVersion);
    }

    return AppVersion.fromRemote(remoteVersion, null, Uri.parse(url!));
  }
}
