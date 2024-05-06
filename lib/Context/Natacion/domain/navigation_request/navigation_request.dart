import 'dart:convert';

import 'package:uuid/uuid.dart';

import '../screen/screen.dart';
import '../screen/sub_screen.dart';
import 'navigation_request_id.dart';

enum RequestType {
  screen(name: 'screen');

  final String name;

  const RequestType({required this.name});

  factory RequestType.fromString(String requestType) {
    switch (requestType) {
      case 'screen':
        return RequestType.screen;
      default:
        throw ArgumentError('Invalid request type: $requestType');
    }
  }
}

class NavigationRequest {
  static const requestTypeKey = 'requestType';
  static const requestScreenFullPathKey = 'fullPath';

  final NavigationRequestId _id;
  final RequestType _navigationType;
  final Screen _screenDestination;

  RequestType get navigationType => _navigationType;
  Screen get destination => _screenDestination;

  NavigationRequest(this._id, this._navigationType, this._screenDestination);

  factory NavigationRequest.fromRaw(Map<String, dynamic> rawData) {
    final requestType = RequestType.fromString(rawData[requestTypeKey]);
    // todo uuid should be part of the raw
    return NavigationRequest(const Uuid().v4(), requestType,
        Screen.fromString(rawData[requestScreenFullPathKey]));
  }

  Map<String, dynamic> toRaw() {
    return ({
      requestScreenFullPathKey: _screenDestination.path,
      requestTypeKey: _navigationType.name
    });
  }
}
