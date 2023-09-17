import '../../../Shared/domain/DomainEvent.dart';

class ChangedCurrentScreenDomainEvent extends DomainEvent {
  final String newScreenName;

  static const String EVENT_NAME = 'screen.changed_current_screen';

  ChangedCurrentScreenDomainEvent._internal(
      super.aggregateId, super.occurredOn, super.eventName, this.newScreenName);

  ChangedCurrentScreenDomainEvent(
      String aggregateId, DateTime occurredOn, String newScreenName)
      : this._internal(aggregateId, occurredOn, EVENT_NAME, newScreenName);
}
