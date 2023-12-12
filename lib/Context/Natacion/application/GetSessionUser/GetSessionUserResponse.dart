import '../../../Shared/application/QueryResponse.dart';

class GetSessionUserResponse implements QueryResponse {
  final bool isLogged;
  final String email;
  late final String memberStatus;
  final bool canUseApp;

  GetSessionUserResponse(
      this.isLogged, this.email, this.canUseApp, String memberStatus) {
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
