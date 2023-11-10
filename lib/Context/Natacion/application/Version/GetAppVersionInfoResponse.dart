import '../../../Shared/application/QueryResponse.dart';

class GetAppVersionInfoResponse implements QueryResponse {
  String currentVersion;
  String? latestVersion;
  String? latestVersionUrl;
  bool shouldUpdate;

  GetAppVersionInfoResponse(this.currentVersion, this.shouldUpdate,
      this.latestVersion, this.latestVersionUrl);
}
