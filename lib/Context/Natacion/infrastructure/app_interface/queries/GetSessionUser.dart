import '../../../application/GetSessionUser/GetSessionUser.dart'
    as GetSessionUserApp;
import '../../../application/GetSessionUser/GetSessionUserResponse.dart';
import '../query_interface.dart';

class GetSessionUser implements QueryInterface<Future<GetSessionUserResponse>> {
  @override
  Future<GetSessionUserResponse> call() {
    return GetSessionUserApp.GetSessionUser()();
  }
}
