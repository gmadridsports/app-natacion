import 'package:gmadrid_natacion/Context/Natacion/application/Version/GetAppVersionInfoResponse.dart';

import '../../../application/Version/GetAppVersionInfo.dart'
    as GetVersionInfoApp;
import '../query_interface.dart';

class GetVersionInfo
    implements QueryInterface<Future<GetAppVersionInfoResponse>> {
  @override
  Future<GetAppVersionInfoResponse> call() {
    return GetVersionInfoApp.GetAppVersionInfo()();
  }
}
