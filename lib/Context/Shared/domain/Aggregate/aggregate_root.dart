import '../DomainEvent.dart';

abstract class AggregateRoot {
  List<DomainEvent> _domainEvents = [];

  List<DomainEvent> pullDomainEvents() {
    final domainEvents = _domainEvents;
    _domainEvents = [];
    return domainEvents;
  }

  // can I do it as an extension function
  List<DomainEvent> get domainEvents => _domainEvents;

  record(DomainEvent domainEvent) {
    _domainEvents.add(domainEvent);
  }
}
