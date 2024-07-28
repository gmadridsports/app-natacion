import '../../../Shared/domain/DomainEvent.dart';

class ChangedCurrentScreenDomainEvent extends DomainEvent {
  final String newScreenPath;
  final bool changedFromUi;
  final bool isOverlayedScreen;
  final Map<String, String> screenData;

  static const String EVENT_NAME = 'screen.changed_current_screen';

  ChangedCurrentScreenDomainEvent._internal(
      super.aggregateId,
      super.occurredOn,
      super.eventName,
      this.newScreenPath,
      this.changedFromUi,
      this.isOverlayedScreen,
      this.screenData);

  ChangedCurrentScreenDomainEvent(String aggregateId, DateTime occurredOn,
      String newScreenName, bool changedFromUi,
      {bool isOverlayedScreen = false,
      Map<String, String> screenData = const {}})
      : this._internal(aggregateId, occurredOn, EVENT_NAME, newScreenName,
            changedFromUi, isOverlayedScreen, screenData);
}
