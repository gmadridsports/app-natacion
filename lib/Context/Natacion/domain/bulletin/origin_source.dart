import 'package:gmadrid_natacion/Context/Shared/domain/value_object.dart';

enum OriginSource implements ValueObject {
  whatsapp(source: 'whatsapp oficial'),
  system(source: 'aplicación');

  const OriginSource({required String source}) : _source = source;

  factory OriginSource.fromString(String source) {
    switch (source.trim()) {
      case 'whatsapp':
        return OriginSource.whatsapp;
      case 'aplicación':
        return OriginSource.system;
      default:
        throw new ArgumentError('Invalid origin source: $source');
    }
  }

  final String _source;

  @override
  String toString() {
    return _source;
  }
}
