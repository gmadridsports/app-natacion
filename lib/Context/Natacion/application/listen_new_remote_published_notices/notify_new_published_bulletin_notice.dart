import 'package:gmadrid_natacion/Context/Natacion/domain/bulletin/bulletin_notifier_service.dart';
import 'package:gmadrid_natacion/shared/dependency_injection.dart';
import '../../../Shared/domain/Bus/Event/EventBus.dart' as DomainEventBus;

import '../../domain/bulletin/Notice.dart';

class NotifyNewPublishedBulletinNotice {
  late final BulletinNotifierService _notifierService;

  NotifyNewPublishedBulletinNotice() {
    _notifierService =
        DependencyInjection().getInstanceOf<BulletinNotifierService>();
  }

  void call(Notice newNotice) {
    newNotice.declareJustPublished();
    _notifierService.save(newNotice);
  }
}
