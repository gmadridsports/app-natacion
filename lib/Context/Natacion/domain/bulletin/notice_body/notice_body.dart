import 'package:gmadrid_natacion/Context/Shared/domain/value_object.dart';

class NoticeBody extends ValueObject {
  String _markdownedBody;

  NoticeBody._internal(String body) : _markdownedBody = body {}

  NoticeBody.fromPrimitives(String body) : this._internal(body);

  @override
  String toString() {
    return _markdownedBody;
  }
}
