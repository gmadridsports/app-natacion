import 'package:gmadrid_natacion/Context/Shared/domain/date_time/madrid_date_time.dart';

import '../../../Shared/domain/DomainEventSubscriber.dart';
import '../../domain/bulletin/Notice.dart';
import '../../domain/bulletin/listened_events/new_published_notice_received.dart';
import 'notify_new_published_bulletin_notice.dart';

class NotifyNewBulletinNoticeOnNewNotice
    implements DomainEventSubscriber<NewPublishedNoticeReceived> {
  @override
  get subscribedTo => NewPublishedNoticeReceived;

  NotifyNewBulletinNoticeOnNewNotice();

  @override
  call(NewPublishedNoticeReceived domainEvent) {
    NotifyNewPublishedBulletinNotice()(Notice.fromRemote(
        domainEvent.body,
        MadridDateTime.fromMicrosecondsSinceEpoch(
            domainEvent.publicationDate.microsecondsSinceEpoch),
        domainEvent.aggregateId,
        domainEvent.origin));
  }
}
