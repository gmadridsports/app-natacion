import '../../../Shared/domain/DomainEvent.dart';

/// Domain event to announce that the current screen has not changed
/// This happens when the user - or any other actor like a domain event reaction - tries to navigate to the same screen
/// This event is useful for the current screen to know that something happened and it may refresh itself like it was a new screen.
/// i.e. the app was on background, the user clicked on a notification and the app was brought to foreground
class NotChangedCurrentScreenDomainEvent extends DomainEvent {
  final String screenPath;

  static const String EVENT_NAME = 'screen.not_changed_current_screen';

  NotChangedCurrentScreenDomainEvent._internal(
      super.aggregateId, super.occurredOn, super.eventName, this.screenPath);

  NotChangedCurrentScreenDomainEvent(
      String aggregateId, DateTime occurredOn, String screenName)
      : this._internal(aggregateId, occurredOn, EVENT_NAME, screenName);
}
