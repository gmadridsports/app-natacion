// this is needed because clock.withDate does not work well when called on
// build methods. it makes mocking things quite difficult, the code should
// be molded on this bug.
import '../domain/DateTimeRepository.dart';

class SystemDateTimeRepository implements DateTimeRepository {
  @override
  DateTime now() => DateTime.now();

  const SystemDateTimeRepository();
}
