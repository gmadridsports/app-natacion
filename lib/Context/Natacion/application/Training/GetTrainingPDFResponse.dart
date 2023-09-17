import 'dart:typed_data';

import '../../../Shared/application/QueryResponse.dart';

class GetTrainingPDFResponse implements QueryResponse {
  final Uint8List rawBytes;

  GetTrainingPDFResponse(this.rawBytes);
}
