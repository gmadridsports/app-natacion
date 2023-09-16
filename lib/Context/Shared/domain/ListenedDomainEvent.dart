import 'DomainEvent.dart';

abstract class ListenedDomainEvent extends DomainEvent {
  ListenedDomainEvent(super.aggregateId, super.occurredOn, super.eventName);
}
