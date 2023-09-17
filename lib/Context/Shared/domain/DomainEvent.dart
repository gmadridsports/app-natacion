abstract class DomainEvent {
  late final String aggregateId;
  late final DateTime occurredOn;
  late final String eventName;

  DomainEvent(this.aggregateId, this.occurredOn, this.eventName);

  static fromPrimitivesArguments(
      String aggregateId, String occuredOn, String eventName) {
    throw UnimplementedError();
  }

  static T fromPrimitives<T extends DomainEvent>(T, List<dynamic> arguments) {
    return T.fromPrimitivesArguments(arguments);
  }
}
