import 'navigation_request.dart';

abstract class NavigationRequestRepository {
  Future<NavigationRequest?> pullLatestNavigationRequest();
  saveNavigationRequest(NavigationRequest navigationRequest);
}
