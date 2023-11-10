import 'dart:ffi';

import 'GetAppVersionInfoResponse.dart';
import '../../../../shared/dependency_injection.dart';
import '../../domain/app/VersionRepository.dart';

class GetAppVersionInfo {
  final VersionRepository _versionRepository;

  GetAppVersionInfo()
      : _versionRepository =
            DependencyInjection().getInstanceOf<VersionRepository>();

  Future<GetAppVersionInfoResponse> call() async {
    final currentVersion = await _versionRepository.getRunningVersion();
    final latestAppVersion =
        await _versionRepository.getLatestAvailableVersion();

    return GetAppVersionInfoResponse(
      currentVersion.version.toString(),
      currentVersion.shouldUpdate,
      latestAppVersion?.version?.toString(),
      latestAppVersion?.versionUrl?.toString(),
    );
  }
}
