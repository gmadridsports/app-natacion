import 'package:gmadrid_natacion/Context/Natacion/application/get_bulletin_notices/get_bulletin_notices_response.dart';
import 'package:gmadrid_natacion/Context/Natacion/domain/bulletin/BulletinRepository.dart';
import 'package:gmadrid_natacion/Context/Shared/domain/date_time/madrid_date_time.dart';

import '../../../../shared/dependency_injection.dart';

class GetBulletinNotices {
  late final BulletinRepository _bulletinRepository;

  GetBulletinNotices() {
    DependencyInjection().getInstanceOf<BulletinRepository>();
    _bulletinRepository =
        DependencyInjection().getInstanceOf<BulletinRepository>();
  }

  Future<GetBulletinNoticesResponse> call(
      (
        MadridDateTime olderThanDateExcluded,
        String? beforeIdExcluded
      ) olderThan) async {
    final notices = await _bulletinRepository.getNotices(olderThan);

    return GetBulletinNoticesResponse.fromDomain(
        notices, _bulletinRepository.paginationSize);
  }
}
