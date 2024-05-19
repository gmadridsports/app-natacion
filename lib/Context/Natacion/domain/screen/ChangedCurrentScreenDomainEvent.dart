import '../../../Shared/domain/DomainEvent.dart';

class ChangedCurrentScreenDomainEvent extends DomainEvent {
  final String newScreenPath;
  final bool changedFromUi;

  static const String EVENT_NAME = 'screen.changed_current_screen';

  ChangedCurrentScreenDomainEvent._internal(super.aggregateId, super.occurredOn,
      super.eventName, this.newScreenPath, this.changedFromUi);

  ChangedCurrentScreenDomainEvent(String aggregateId, DateTime occurredOn,
      String newScreenName, bool changedFromUi)
      : this._internal(
            aggregateId, occurredOn, EVENT_NAME, newScreenName, changedFromUi);
}
