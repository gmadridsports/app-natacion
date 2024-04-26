import 'package:gmadrid_natacion/Context/Natacion/domain/bulletin/Notice.dart';
import 'package:gmadrid_natacion/Context/Natacion/domain/bulletin/bulletin_notifier_service.dart';
import 'package:gmadrid_natacion/shared/dependency_injection.dart';
import '../../../Shared/infrastructure/Bus/Event/LibEventBusEventBus.dart';

class LibEventBusBulletinNotifierService extends BulletinNotifierService {
  LibEventBusBulletinNotifierService() {}

  @override
  void save(Notice notice) {
    final domainEvents = notice.pullDomainEvents();
    final eventBus = DependencyInjection().getInstanceOf<LibEventBusEventBus>();
    eventBus.publishApp(domainEvents);
    eventBus.publish(domainEvents);
  }
}
