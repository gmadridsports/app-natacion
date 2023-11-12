import 'AppVersion.dart';

abstract class VersionRepository {
  Future<AppVersion> getRunningVersion();
  Future<AppVersion?> getLatestAvailableVersion();
}
