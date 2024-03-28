import 'package:gmadrid_natacion/Context/Natacion/domain/bulletin/BulletinRepository.dart';
import 'package:gmadrid_natacion/Context/Natacion/domain/bulletin/Notice.dart';
import 'package:gmadrid_natacion/Context/Shared/domain/date_time/madrid_date_time.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseBulletinRepository implements BulletinRepository {
  static const String _bulletinTable = 'bulletin_board';
  static const String _isPublishedColumn = 'is_published';
  static const String _idColumn = 'id';
  static const String _pubblicationDateColumn = 'publication_date';
  static const String _originColumn = 'origin_source';
  static const String _bodyMessageColumn = 'body_message';

  @override
  Future<List<Notice>> getNotices(
      (
        MadridDateTime olderThanDateExcluded,
        String? beforeIdExcluded
      ) olderThan,
      {int limit = BulletinRepository.PAGINATION_SIZE}) async {
    final List<dynamic> returnedNotices = await (olderThan.$2 != null
        ? (Supabase.instance.client
            .from(_bulletinTable)
            .select(
                "$_bodyMessageColumn,$_idColumn,$_pubblicationDateColumn,$_originColumn")
            .filter(_isPublishedColumn, 'eq', true)
            .or(
                '${_pubblicationDateColumn}.lt.${olderThan.$1},and(${_pubblicationDateColumn}.eq.${olderThan.$1},${_idColumn}.lt.${olderThan.$2})')
            .order(_pubblicationDateColumn, ascending: false)
            .order(_idColumn, ascending: false)
            .limit(limit))
        : (Supabase.instance.client
            .from(_bulletinTable)
            .select(
                "$_bodyMessageColumn,$_idColumn,$_pubblicationDateColumn,$_originColumn")
            .filter(_isPublishedColumn, 'eq', true)
            .filter(_pubblicationDateColumn, 'lte', olderThan.$1)
            .order(_pubblicationDateColumn, ascending: false)
            .order(_idColumn, ascending: false)
            .limit(limit)));

    if (returnedNotices.isEmpty) {
      return [];
    }

    // todo datetime madrid VO?
    return returnedNotices
        .map((notice) => Notice.fromRemote(
            notice[_bodyMessageColumn],
            MadridDateTime.fromMicrosecondsSinceEpoch(
                DateTime.parse(notice[_pubblicationDateColumn])
                    .microsecondsSinceEpoch),
            notice[_idColumn],
            notice[_originColumn]))
        .toList();
  }

  @override
  get paginationSize => BulletinRepository.PAGINATION_SIZE;
}
