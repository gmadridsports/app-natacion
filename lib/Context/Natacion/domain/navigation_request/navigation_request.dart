import 'package:uuid/uuid.dart';

import '../screen/screen.dart';
import 'navigation_request_id.dart';
import 'dart:convert';

enum RequestType {
  screen(name: 'screen'),
  overlayedScreen(name: 'overlayed-screen');

  final String name;

  const RequestType({required this.name});

  factory RequestType.fromString(String requestType) {
    switch (requestType) {
      case 'screen':
        return RequestType.screen;
      case 'overlayed-screen':
        return RequestType.overlayedScreen;
      default:
        throw ArgumentError('Invalid request type: $requestType');
    }
  }
}

Map<String, String> convertToMapStringString(Map<String, dynamic> rawData) {
  final mapToReturn = <String, String>{};
  rawData.forEach((key, value) {
    if (value != null) {
      mapToReturn[key] = value.toString();
    }
  });
  return mapToReturn;
}

class NavigationRequest {
  static const requestTypeKey = 'requestType';
  static const screenParamsKey = 'screenParams';
  static const requestScreenFullPathKey = 'fullPath';
  final Map<String, String> screenParams;

  final NavigationRequestId _id;
  final RequestType _navigationType;
  final Screen _screenDestination;

  RequestType get navigationType => _navigationType;

  Screen get destination => _screenDestination;

  NavigationRequest(this._id, this._navigationType, this._screenDestination,
      this.screenParams);

  factory NavigationRequest.fromRaw(Map<String, dynamic> rawData) {
    final requestType = RequestType.fromString(rawData[requestTypeKey]);
    print('key');
    print(rawData[screenParamsKey]?.runtimeType);
    print(rawData[screenParamsKey]);
    // print(jsonDecode(rawData[screenParamsKey]));
    // final screenParams = <String, String>{"url": "https://www.google.com"};
    final screenParams =
        rawData.containsKey(screenParamsKey) && rawData[screenParamsKey] != null
            ? convertToMapStringString(
                rawData[screenParamsKey].runtimeType == String
                    ? jsonDecode(rawData[screenParamsKey])
                    : rawData[screenParamsKey])
            : <String, String>{};
    print("nav request screenParams");
    print(screenParams);
    // todo uuid should be part of the raw
    return NavigationRequest(const Uuid().v4(), requestType,
        Screen.fromString(rawData[requestScreenFullPathKey]), screenParams);
  }

  factory NavigationRequest.fromScreen(Screen screen,
      {RequestType type = RequestType.screen,
      Map<String, String> params = const {}}) {
    return NavigationRequest(const Uuid().v4(), type, screen, params);
  }

  Map<String, dynamic> toRaw() {
    return ({
      requestScreenFullPathKey: _screenDestination.path,
      requestTypeKey: _navigationType.name,
      screenParamsKey: screenParams
    });
  }
}
