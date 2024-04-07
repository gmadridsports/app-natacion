import 'package:gmadrid_natacion/Context/Natacion/domain/bulletin/notice_published_event.dart';
import 'package:gmadrid_natacion/Context/Natacion/domain/bulletin/origin_source.dart';
import 'package:gmadrid_natacion/Context/Shared/domain/date_time/madrid_date_time.dart';

import '../../../Shared/domain/Aggregate/aggregate_root.dart';
import 'notice_body/notice_body.dart';

class Notice extends AggregateRoot {
  final NoticeBody _body;
  final MadridDateTime _publicationDate;
  final String _id;
  final OriginSource _origin;

  MadridDateTime get publicationDate => _publicationDate;

  NoticeBody get body => _body;

  String get id => _id;

  String get origin => _origin.toString();

  Notice._internal(
    this._publicationDate,
    this._id,
    this._origin,
    this._body,
  );

  Notice.fromRemote(
      String body, MadridDateTime publicationDate, String id, String origin)
      : this._internal(publicationDate, id, OriginSource.fromString(origin),
            NoticeBody.fromPrimitives(body));

  void declareJustPublished() {
    record(NoticePublishedEvent(_id, DateTime.now(), _body.toString(),
        _publicationDate, _id, _origin.toString()));
  }
}
