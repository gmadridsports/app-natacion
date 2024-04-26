import '../../../../shared/dependency_injection.dart';
import '../../domain/bulletin/new_published_notice_listener.dart';

class ListenNewRemoteNotices {
  NewPublishedNoticeListener _listener;

  call() async {
    _listener.listen();
  }

  ListenNewRemoteNotices()
      : _listener =
            DependencyInjection().getInstanceOf<NewPublishedNoticeListener>();
}
