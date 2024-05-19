import 'dart:convert';

import 'package:gmadrid_natacion/Context/Natacion/domain/navigation_request/navigation_request_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/navigation_request/navigation_request.dart';

class SharedPreferencesNavigationRequestRepository
    implements NavigationRequestRepository {
  static const String _navigationRequestKey = 'navigation-request';

  Future<NavigationRequest?> _getLatestNavigationRequest() async {
    final prefs = await SharedPreferences.getInstance();
    final latestNavigationRequest = prefs.getString(_navigationRequestKey);

    if (latestNavigationRequest == null) {
      return null;
    }

    final raw = jsonDecode(latestNavigationRequest);
    return NavigationRequest.fromRaw(raw);
  }

  Future<void> _storeNavigationRequest(
      NavigationRequest navigationRequest) async {
    final prefs = await SharedPreferences.getInstance();
    final rawVal = navigationRequest.toRaw();
    final success =
        await prefs.setString(_navigationRequestKey, jsonEncode(rawVal));

    if (!success) {
      throw Exception("Impossible storing the navigation request");
    }
  }

  @override
  Future<NavigationRequest?> pullLatestNavigationRequest() async {
    final latestNavigationRequest = await _getLatestNavigationRequest();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_navigationRequestKey);

    return latestNavigationRequest;
  }

  @override
  saveNavigationRequest(NavigationRequest navigationRequest) async {
    final latestNavigationRequest = await _getLatestNavigationRequest();
    if (latestNavigationRequest != null) {
      throw ArgumentError("another request is in progress");
    }

    await _storeNavigationRequest(navigationRequest);
  }
}
