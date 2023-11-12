import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gmadrid_natacion/Context/Natacion/application/Version/GetAppVersionInfoResponse.dart';
import 'package:gmadrid_natacion/Context/Natacion/infrastructure/app_interface/queries/get_version_info.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../Context/Natacion/application/GetSessionUser/GetSessionUserResponse.dart';
import '../../../../Context/Natacion/infrastructure/app_interface/commands/logout_user.dart';
import '../../../../Context/Natacion/infrastructure/app_interface/queries/GetSessionUser.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final _user = GetSessionUser()();
  final _version = GetVersionInfo()();

  @override
  FutureBuilder<List<Object>> build(BuildContext context) {
    return FutureBuilder(
        future: Future.wait([_user, _version]),
        builder: (BuildContext context, AsyncSnapshot<List<Object>> snapshots) {
          if (!snapshots.hasData && !snapshots.hasError) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshots.data![0] as GetSessionUserResponse;
          final versionInfo = snapshots.data![1] as GetAppVersionInfoResponse;

          return ListView(children: [
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
            ListTile(
              leading: const Icon(Icons.bug_report),
              title: const Text('Reporta problemas o ideas'),
              onTap: () => _launchURL(
                  'https://forms.gle/C6rrXmHaoyhsyfAG9', context,
                  innerWebView: true),
            ),
            ListTile(
                key: const Key('version'),
                leading:
                    versionInfo.shouldUpdate ? const Icon(Icons.update) : null,
                title: Text('Versión ${versionInfo.currentVersion.toString()}'),
                onTap: () => _launchURL(
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
                onTap: () => _launchURL('https://bertamini.net', context),
                subtitle: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Matteo Bertamini | www.bertamini.net'),
                      Text('Bajo licencia MIT')
                    ]),
                isThreeLine: false),
          ]);
        });
  }

  _launchURL(String url, BuildContext context, {innerWebView = false}) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(
        Uri.parse(url),
        mode: innerWebView == false
            ? LaunchMode.externalApplication
            : LaunchMode.inAppWebView,
        webViewConfiguration:
            const WebViewConfiguration(enableJavaScript: true),
      );
    } else {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content:
              const Text('No se puede abrir el enlace en este dispositivo')));
      throw 'Could not launch $url';
    }
  }

// @override
// Widget build(BuildContext context) {
//   return (const Text('ciao'));
//   // TODO: implement build
//   throw UnimplementedError();
// }
}
