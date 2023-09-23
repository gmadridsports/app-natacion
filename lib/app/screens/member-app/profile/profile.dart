import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gmadrid_natacion/Context/Natacion/application/GetSessionUser/GetSessionUser.dart';
import 'package:gmadrid_natacion/Context/Natacion/application/GetSessionUser/GetSessionUserResponse.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../Context/Natacion/application/LogoutUser/LogoutUser.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final _user = GetSessionUser()();
  final _packageInfo = PackageInfo.fromPlatform();

  @override
  FutureBuilder<List<Object>> build(BuildContext context) {
    return FutureBuilder(
        future: Future.wait([_user, _packageInfo]),
        builder: (BuildContext context, AsyncSnapshot<List<Object>> snapshots) {
          if (!snapshots.hasData && !snapshots.hasError) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshots.data![0] as GetSessionUserResponse;
          final packageInfo = snapshots.data![1] as PackageInfo;

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
                title: Text(
                    'Versión ${packageInfo.version} build ${packageInfo.buildNumber}'),
                onTap: () => _launchURL(
                    'https://gmadridnatacion.bertamini.net', context),
                subtitle: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('https://gmadridnatacion.bertamini.net'),
                  ],
                ),
                isThreeLine: false),
            ListTile(
                title: const Text('Desarrollo'),
                onTap: () => _launchURL('https://bertamini.net', context),
                subtitle: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Matteo Bertamini'),
                      Text('www.bertamini.net'),
                      Text('Bajo licencia MIT')
                    ]),
                isThreeLine: false),
          ]);
        });
  }

  _launchURL(String url, BuildContext context) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
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
}
