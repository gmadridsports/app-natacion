import 'package:gmadrid_natacion/Context/Shared/domain/value_object.dart';

enum OriginSource implements ValueObject {
  whatsapp(source: 'whatsapp oficial'),
  system(source: 'aplicación'),
  other(source: 'otras');

  const OriginSource({required String source}) : _source = source;

  factory OriginSource.fromString(String source) {
    switch (source.trim()) {
      case 'whatsapp':
        return OriginSource.whatsapp;
      case 'aplicación':
        return OriginSource.system;
      default:
        return OriginSource.other;
    }
  }

  final String _source;

  @override
  String toString() {
    switch (this) {
      case OriginSource.whatsapp:
        return 'Grupo oficial ws';
      case OriginSource.system:
        return 'Aplicación';
      case OriginSource.other:
        return 'Otra origen';
    }
  }
}
