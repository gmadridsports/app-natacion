import 'package:gmadrid_natacion/Context/Natacion/domain/navigation_request/navigation_request_repository.dart';

import '../../../../shared/dependency_injection.dart';
import '../../domain/navigation_request/navigation_request.dart';

class SaveNavigationRequest {
  final NavigationRequestRepository _navigationRequestRepository;

  SaveNavigationRequest()
      : _navigationRequestRepository =
            DependencyInjection().getInstanceOf<NavigationRequestRepository>();

  Future<void> call(Map<String, dynamic> data) async {
    final navigationRequest = NavigationRequest.fromRaw(data);
    await _navigationRequestRepository.saveNavigationRequest(navigationRequest);
  }
}
