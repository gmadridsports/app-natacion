import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gmadrid_natacion/Context/Natacion/application/Version/GetAppVersionInfoResponse.dart';
import 'package:gmadrid_natacion/Context/Natacion/domain/user/notification_preferences.dart';
import 'package:gmadrid_natacion/Context/Natacion/infrastructure/app_interface/queries/get_version_info.dart';
import 'package:gmadrid_natacion/app/screens/NamedRouteScreen.dart';
import 'package:gmadrid_natacion/app/screens/member-app/member_app.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:event_bus/event_bus.dart' as LibEventBus;

import '../../../../Context/Natacion/application/update_user/change_notification_preferences.dart';
import '../../../../Context/Natacion/domain/user/notification_preferences.dart'
    as UserDomainNotificationPreferences;
import '../../../../Context/Natacion/application/GetSessionUser/GetSessionUserResponse.dart';
import '../../../../Context/Natacion/domain/user/user_app_notification_preferences_changed_event.dart';
import '../../../../Context/Natacion/infrastructure/app_interface/commands/logout_user.dart';
import '../../../../Context/Natacion/infrastructure/app_interface/queries/GetSessionUser.dart';
import '../../../../Context/Shared/infrastructure/Bus/Event/LibEventBusEventBus.dart';
import '../../../../shared/dependency_injection.dart';
import '../launchURL.dart';

class Profile extends StatefulWidget implements NamedRouteScreen {
  static String get routeName => "${MemberApp.routeName}/profile";

  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

typedef NotificationType = NotificationPreferenceType;

class _ProfileState extends State<Profile> {
  final _user = GetSessionUser()();
  final _version = GetVersionInfo()();

  Map<NotificationType, bool?>? _notificationPreferences;
  StreamSubscription? _streamSubscription;

  @override
  void initState() {
    super.initState();
    _streamSubscription = DependencyInjection()
        .getInstanceOf<LibEventBus.EventBus>()
        .on<AppEventType>()
        .listen((event) async {
      if (event.payload.eventName !=
          UserAppNotificationPreferencesChanged.EVENT_NAME) {
        return;
      }
      final preferences =
          (event.payload as UserAppNotificationPreferencesChanged).preferences;

      setState(() {
        if (_notificationPreferences == null) {
          return;
        }
        _notificationPreferences![NotificationType.other] =
            preferences[NotificationType.other.name]!;
        // _notificationPreferences[NotificationType.trainingWeek.name] =
        //     preferences[NotificationType.trainingWeek.name]!;
        // _notificationPreferences[NotificationType.bulletinBoard.name] =
        //     preferences[NotificationType.bulletinBoard.name]!;
      });
    });
  }

  @override
  dispose() {
    super.dispose();
    _streamSubscription?.cancel();
  }

  _handleChangeNotificationPreferences(
      NotificationType notification, bool value) {
    setState(() {
      _notificationPreferences![notification] = value;
    });

    try {
      ChangeNotificationPreference()(
          ChangeNotificationPreferenceRequest(notification.name, value));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.red, content: Text("Ha ocurrido un error")));
      _notificationPreferences![notification] = !value;
    }
  }

  @override
  FutureBuilder<List<Object>> build(BuildContext context) {
    return FutureBuilder(
        future: Future.wait([_user, _version]),
        builder: (BuildContext context, AsyncSnapshot<List<Object>> snapshots) {
          if (!snapshots.hasData && !snapshots.hasError) {
            return Container(
                color: Colors.white,
                child: const Center(child: CircularProgressIndicator()));
          }

          final user = snapshots.data![0] as GetSessionUserResponse;
          _notificationPreferences ??= {
            NotificationType.other: user.notificationPreferences.other,
            NotificationType.bulletinBoard:
                user.notificationPreferences.bulletinBoard,
            NotificationType.trainingWeek:
                user.notificationPreferences.weeklyTraining
          };
          final versionInfo = snapshots.data![1] as GetAppVersionInfoResponse;

          return Container(
            color: Colors.white,
            child: ListView(children: [
              const ListTile(
                title: Text('Mi sesión',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              ListTile(
                  leading: Icon(Icons.email),
                  title: Text('Mi correo'),
                  subtitle: Text(user.email)),
              ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Mi estado'),
                  subtitle: Text(user.memberStatus)),
              ListTile(
                key: const Key('logout'),
                leading: Icon(Icons.logout),
                title: const Text('Cierra la sesión'),
                onTap: () async {
                  LogoutUser()();
                },
              ),
              const Divider(
                thickness: 1,
              ),
              const ListTile(
                title: Text('Notificaciones',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                // subtitle:
                //     Text('Elige el tipo de notificaciones push que recibes'),
              ),
              SwitchListTile(
                  key: ValueKey(NotificationPreferenceType.trainingWeek.name),
                  title: const Text('Entreno disponible'),
                  // le
                  subtitle: const Text('Comúnmente semanal'),
                  value: _notificationPreferences![
                          NotificationPreferenceType.trainingWeek] ??
                      user.notificationPreferences.weeklyTraining,
                  onChanged: (value) {
                    _handleChangeNotificationPreferences(
                        NotificationType.trainingWeek, value);
                  }),
              SwitchListTile(
                  key: ValueKey(NotificationPreferenceType.bulletinBoard.name),
                  title: const Text('Avisos'),
                  subtitle:
                      const Text('Comunicaciones importantes y/u oficiales'),
                  value: _notificationPreferences![
                          NotificationPreferenceType.bulletinBoard] ??
                      user.notificationPreferences.bulletinBoard,
                  onChanged: (value) {
                    _handleChangeNotificationPreferences(
                        NotificationType.bulletinBoard, value);
                  }),
              SwitchListTile(
                  key: ValueKey(NotificationPreferenceType.other.name),
                  title: const Text('Otras'),
                  subtitle: const Text('Carácter general o sobre la App.'),
                  value: _notificationPreferences![
                          NotificationPreferenceType.other] ??
                      user.notificationPreferences.other,
                  onChanged: (value) {
                    _handleChangeNotificationPreferences(
                        NotificationType.other, value);
                  }),
              const Divider(
                thickness: 1,
              ),
              const ListTile(
                  title: Text('Aplicación',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              ListTile(
                leading: const Icon(Icons.bug_report),
                title: const Text('Reporta problemas o ideas'),
                onTap: () => launchURL(
                    'https://forms.gle/C6rrXmHaoyhsyfAG9', context,
                    innerWebView: true),
              ),
              ListTile(
                  key: const Key('version'),
                  leading: versionInfo.shouldUpdate
                      ? const Icon(Icons.update)
                      : const Icon(Icons.check),
                  title:
                      Text('Versión ${versionInfo.currentVersion.toString()}'),
                  onTap: () => launchURL(
                      versionInfo.shouldUpdate
                          ? versionInfo.latestVersionUrl ??
                              'https://gmadridnatacion.bertamini.net'
                          : 'https://gmadridnatacion.bertamini.net',
                      context),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (versionInfo.shouldUpdate)
                        Text(
                            'Actualización disponible: ${versionInfo.latestVersion}'),
                      if (versionInfo.shouldUpdate)
                        const Text('Pincha para descargar la última versión'),
                      if (!versionInfo.shouldUpdate)
                        const Text('https://gmadridnatacion.bertamini.net'),
                    ],
                  ),
                  isThreeLine: versionInfo.shouldUpdate),
              const Divider(
                thickness: 1,
              ),
              ListTile(
                  title: const Text('Desarrollo'),
                  onTap: () => launchURL('https://bertamini.net', context),
                  subtitle: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Matteo Bertamini | www.bertamini.net'),
                        Text('Bajo licencia GNU Affero General Public License')
                      ]),
                  isThreeLine: false),
            ]),
          );
        });
  }
}
