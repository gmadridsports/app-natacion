import 'package:gmadrid_natacion/Context/Shared/domain/date_time/madrid_date_time.dart';

import '../../../Shared/domain/DomainEvent.dart';

class NoticePublishedEvent extends DomainEvent {
  final String body;
  final DateTime publicationDate;
  final String id;
  final String origin;

  static const String EVENT_NAME = 'bulletin.new_notice_published';

  NoticePublishedEvent._internal(super.aggregateId, super.occurredOn,
      super.eventName, this.body, this.publicationDate, this.id, this.origin);

  NoticePublishedEvent(String aggregateId, DateTime occurredOn, String body,
      MadridDateTime publicationDate, String id, String origin)
      : this._internal(aggregateId, occurredOn, EVENT_NAME, body,
            publicationDate.toDateTime(), id, origin);
}
