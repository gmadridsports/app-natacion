import 'package:gmadrid_natacion/Context/Natacion/domain/bulletin/notice_body/body_parser_factory.dart';
import 'package:gmadrid_natacion/Context/Natacion/domain/bulletin/origin_source.dart';
import 'package:gmadrid_natacion/Context/Shared/domain/value_object.dart';

class NoticeBody extends ValueObject {
  String _markdownedBody;

  NoticeBody._internal(String body) : _markdownedBody = body {}

  NoticeBody.from(String rawBody, OriginSource origin)
      : this._internal(BodyParserFactory.getParser(origin).parse(rawBody));

  @override
  String toString() {
    return _markdownedBody;
  }
}
