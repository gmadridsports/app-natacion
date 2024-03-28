import 'package:gmadrid_natacion/Context/Natacion/domain/bulletin/notice_body/body_parser_factory.dart';

class WhatsappBodyParser implements BodyParser {
  @override
  String parse(String rawBody) {
    return rawBody.replaceAllMapped(
        RegExp(
            r'(_|\*)([^_]+?)(_|\*)(?=\s|\n|$)|(~{2})([^~]+?)(~{2})|(`{3})([^`]+?)(`{3})|(`)([^`]+?)(`)'),
        (match) {
      return match.group(0) != null ? '**${match.group(0)}**' : '';
    });
  }
}
