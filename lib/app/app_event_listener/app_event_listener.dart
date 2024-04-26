import 'dart:async';

import 'package:event_bus/event_bus.dart' as LibEventBus;

import '../../Context/Shared/domain/DomainEvent.dart';
import '../../Context/Shared/infrastructure/Bus/Event/LibEventBusEventBus.dart';
import '../../shared/dependency_injection.dart';

class AppEventListener {
  late final StreamSubscription _streamSubscription;

  static final Finalizer<(StreamSubscription, Function()?)> _finalizer =
      Finalizer((params) {
    params.$1.cancel();
    if (params.$2 != null) {
      params.$2!();
    }
  });

  AppEventListener();

  void onAppBCEvent<T extends DomainEvent>(
      String eventName, Function(T) callback,
      {Function()? triggerBCListener, Function()? stopBCListener}) {
    _streamSubscription = DependencyInjection()
        .getInstanceOf<LibEventBus.EventBus>()
        .on<AppEventType>()
        .listen((event) async {
      if (event.payload.eventName != eventName) {
        return;
      }

      callback(event.payload as T);
    });

    if (triggerBCListener != null) {
      triggerBCListener();
    }
    _finalizer.attach(this, (_streamSubscription, stopBCListener),
        detach: this);
  }

  void stopListening() {
    _streamSubscription.cancel();
  }
}
