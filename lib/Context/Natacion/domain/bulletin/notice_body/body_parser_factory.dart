import 'package:gmadrid_natacion/Context/Natacion/domain/bulletin/origin_source.dart';

import 'raw_body_parser.dart';
import 'whatsapp_body_parser.dart';

abstract class BodyParser {
  String parse(String rawBody);
}

class BodyParserFactory {
  static BodyParser getParser(OriginSource origin) {
    switch (origin) {
      case OriginSource.whatsapp:
        return WhatsappBodyParser();
      default:
        return RawBodyParser();
    }
  }
}
