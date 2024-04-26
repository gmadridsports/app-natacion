import '../../../Shared/application/QueryResponse.dart';
import '../../domain/bulletin/Notice.dart';

class BulletinNotice {
  final String body;
  final DateTime publicationDate;
  final String id;
  final String origin;
  BulletinNotice(this.body, this.publicationDate, this.id, this.origin);
}

class GetBulletinNoticesResponse implements QueryResponse {
  /// dateTime must be considered as it were on the Madrid timezone.
  /// the timezone is always on UTC, but the date time is considered as it were
  /// on the Madrid timezone.
  /// i.e. 20/01/2024 15:04 UTC -> is describing a 20/01/2024 15:04 Europe/Madrid
  final List<BulletinNotice> notices;
  final bool hasMore;

  GetBulletinNoticesResponse._internal(this.notices, this.hasMore);

  GetBulletinNoticesResponse.fromDomain(
      List<Notice> notices, int bulletinNoticesBulkSize)
      : this._internal(
            notices
                .map((notice) => BulletinNotice(
                    notice.body.toString(),
                    notice.publicationDate.toDateTime(),
                    notice.id,
                    notice.origin))
                .toList(),
            notices.length == bulletinNoticesBulkSize);
}
