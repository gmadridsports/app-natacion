import 'package:gmadrid_natacion/Context/Natacion/domain/app/AppVersion.dart';
import 'package:gmadrid_natacion/Context/Natacion/domain/app/Version.dart';
import 'package:package_info/package_info.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/app/VersionRepository.dart';

class SupabaseVersionRepository implements VersionRepository {
  static const String _versionsTable = 'versions';
  static const String _versionColumn = 'version';
  static const String _updateUrl = 'url';

  const SupabaseVersionRepository();

  @override
  Future<AppVersion> getRunningVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final latestAppVersion = await getLatestAvailableVersion();

    return AppVersion.from(
        Version.from("${packageInfo.version}+${packageInfo.buildNumber}"),
        latestAppVersion?.version);
  }

  Future<AppVersion?> getLatestAvailableVersion() async {
    final List<dynamic> returnedVersion = await Supabase.instance.client
        .from(_versionsTable)
        .select("$_versionColumn, $_updateUrl")
        .filter('available', 'eq', true)
        .order('published_at', ascending: true)
        .limit(1);

    if (returnedVersion.isEmpty) {
      return null;
    }

    return AppVersion.fromRemote(
        Version.from(returnedVersion.firstOrNull[_versionColumn] as String),
        Version.from(returnedVersion.firstOrNull[_versionColumn] as String),
        Uri.parse(returnedVersion.firstOrNull[_updateUrl] as String));
  }
}
