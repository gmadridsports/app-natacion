import 'package:gmadrid_natacion/Context/Shared/domain/value_object.dart';
import 'package:pub_semver/pub_semver.dart' as SemVersion;

class Version implements ValueObject {
  final String _version;
  late final SemVersion.Version _parsedVersion;

  Version._internal({required String version}) : _version = version {
    _parsedVersion = SemVersion.Version.parse(_version);
  }

  Version.from(String version) : this._internal(version: version);

  @override
  String toString() {
    return _parsedVersion.canonicalizedVersion;
  }

  bool updateAvailable(Version? other) {
    if (other == null) {
      return false;
    }

    return _parsedVersion < other._parsedVersion;
  }
}
