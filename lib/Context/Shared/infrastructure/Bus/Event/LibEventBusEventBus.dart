import 'package:event_bus/event_bus.dart';

import '../../../domain/Bus/Event/EventBus.dart' as DomainEventBus;
import '../../../domain/DomainEvent.dart';
import '../../../domain/DomainEventSubscriber.dart';

class BoundedContextDomainEventType {
  final DomainEvent payload;

  BoundedContextDomainEventType(this.payload);
}

// todo https://trello.com/c/Dvxd0Gx0 make it generic so as to listen <AppeventType<DomainEventType>>
class AppEventType<T extends DomainEvent> {
  final T payload;

  AppEventType(this.payload);
}

class LibEventBusEventBus implements DomainEventBus.EventBus {
  final Map<String, List<DomainEventSubscriber>> _subscribers = {};
  final EventBus _eventBus;

  LibEventBusEventBus(this._eventBus,
      {List<DomainEventSubscriber<dynamic>>? subscribers}) {
    subscribers?.forEach((subscriber) {
      associateSubscriber(subscriber);
    });

    _listenToDomainEvents();
  }

  _listenToDomainEvents() {
    _eventBus.on<BoundedContextDomainEventType>().listen((event) {
      Type? type = event.payload?.runtimeType;
      _subscribers[type.toString()]?.forEach((subscriber) {
        subscriber(event.payload);
      });
    });
  }

  @override
  associateSubscriber(DomainEventSubscriber<dynamic> subscriber) {
    _subscribers[subscriber.subscribedTo.toString()] = [
      ..._subscribers[subscriber.subscribedTo.toString()] ?? [],
      subscriber
    ];
  }

  @override
  publish(List<DomainEvent> events) {
    events.forEach((event) {
      BoundedContextDomainEventType eventToFire =
          BoundedContextDomainEventType(event);
      _eventBus.fire(eventToFire);
    });
  }

  // events that are listened by the UI app istelf, not a bounded context
  publishApp<T extends DomainEvent>(List<T> events) {
    events.forEach((event) {
      Type y = event.runtimeType;
      AppEventType eventToFire = AppEventType<T>(event);

      _eventBus.fire(eventToFire);
    });
  }
}
