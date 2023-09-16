import '../../DomainEvent.dart';
import '../../DomainEventSubscriber.dart';

abstract class EventBus {
  associateSubscriber(DomainEventSubscriber subscriber);
  publish(List<DomainEvent> events);
}
