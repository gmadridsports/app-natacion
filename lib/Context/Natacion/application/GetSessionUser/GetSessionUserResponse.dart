import '../../../Shared/application/QueryResponse.dart';

class NotificationPreferences {
  final bool weeklyTraining;
  final bool bulletinBoard;
  final bool other;

  NotificationPreferences(this.weeklyTraining, this.bulletinBoard, this.other);
}

class GetSessionUserResponse implements QueryResponse {
  final bool isLogged;
  final String email;
  late final String memberStatus;
  final bool canUseApp;
  final NotificationPreferences notificationPreferences;

  GetSessionUserResponse(this.isLogged, this.email, this.canUseApp,
      this.notificationPreferences, String memberStatus) {
    switch (memberStatus) {
      case 'user':
        this.memberStatus = 'no miembro';
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
