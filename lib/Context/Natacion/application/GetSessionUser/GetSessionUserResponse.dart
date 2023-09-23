import 'dart:typed_data';

import '../../../Shared/application/QueryResponse.dart';

class GetSessionUserResponse implements QueryResponse {
  final String email;
  late final String memberStatus;

  GetSessionUserResponse(this.email, String memberStatus) {
    switch (memberStatus) {
      case 'user':
        this.memberStatus = 'no miebro';
        break;
      case 'member':
        this.memberStatus = 'miembro 2023/24';
        break;
      case 'ex-member':
        this.memberStatus = 'ex miembro';
        break;
      default:
        this.memberStatus = 'Desconocido';
        break;
    }
  }
}
