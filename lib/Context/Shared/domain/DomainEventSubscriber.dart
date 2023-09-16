import 'ListenedDomainEvent.dart';

abstract class DomainEventSubscriber<T> {
  get subscribedTo => T;

  call(T domainEvent);
}
