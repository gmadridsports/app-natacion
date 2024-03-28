import 'package:gmadrid_natacion/Context/Shared/domain/date_time/madrid_date_time.dart';

import 'Notice.dart';

abstract class BulletinRepository {
  static const int PAGINATION_SIZE = 10;

  get paginationSize => BulletinRepository.PAGINATION_SIZE;

  Future<List<Notice>> getNotices(
      (
        MadridDateTime olderThanDateExcluded,
        String? beforeIdExcluded
      ) olderThan,
      {int limit = 10});
}
