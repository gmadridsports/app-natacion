import '../../../../Shared/domain/ListenedDomainEvent.dart';

class NewPublishedNoticeReceived extends ListenedDomainEvent {
  final String body;
  final String origin;
  final DateTime publicationDate;

  static const String EVENT_NAME = 'bulletin.new_notice_published';

  NewPublishedNoticeReceived._internal(super.aggregateId, super.occurredOn,
      super.eventName, this.body, this.origin, this.publicationDate);

  NewPublishedNoticeReceived(String aggregateId, DateTime occurredOn,
      String body, String origin, DateTime publicationDate)
      : this._internal(
            aggregateId, occurredOn, EVENT_NAME, body, origin, publicationDate);
}
