import '../../../Shared/domain/Aggregate/aggregate_root.dart';
import 'Version.dart';

class AppVersion extends AggregateRoot {
  final Version _version;
  final bool isCurrentAppVersion;
  final bool shouldUpdate;
  final Uri? versionUrl;

  AppVersion._internal(Version version, Version? latestRemoteVersion,
      this.isCurrentAppVersion, this.versionUrl)
      : _version = version,
        shouldUpdate = version.updateAvailable(latestRemoteVersion);

  AppVersion.from(Version appVersion, Version latestRemoteVersion)
      : this._internal(appVersion, latestRemoteVersion, true, null);

  AppVersion.fromRemote(
      Version remoteAppVersion, Version? latestRemoteVersion, Uri versionUrl)
      : this._internal(
            remoteAppVersion, latestRemoteVersion, false, versionUrl);

  get version => _version;
}
