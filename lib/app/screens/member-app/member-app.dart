import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gmadrid_natacion/Context/Natacion/application/Training/GetTrainingPDF.dart';
import 'package:gmadrid_natacion/Context/Natacion/application/TrainingDate/GetTrainingDatesBoundaries.dart';
import 'package:gmadrid_natacion/Context/Natacion/application/TrainingDate/IsATrainingWeek.dart';
import 'package:gmadrid_natacion/shared/dependency_injection.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../Context/Natacion/application/LogoutUser/LogoutUser.dart';
import '../../../Context/Natacion/application/TrainingDate/GetTrainingBoundariesResponse.dart';
import '../../../shared/domain/DateTimeRepository.dart';
import '../../../Context/Natacion/domain/TrainingDate.dart';
import '../NamedRouteScreen.dart';
import '../splash-screen/splash-screen.dart';
import 'pools/pools.dart';
import 'profile/profile.dart';
import 'training-week/training-week.dart';

class MemberApp extends StatefulWidget implements NamedRouteScreen {
  static String get routeName => '/member-app';

  @override
  State<MemberApp> createState() => _MemberAppState();
}

class _MemberAppState extends State<MemberApp> {
  int _selectedTab = 0;
  final _buildBody = const <Widget>[TrainingWeek(), Pools(), Profile()];

  _MemberAppState();

  @override
  void didChangeDependencies() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('GMadrid Natación'),
        ),
        bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedTab,
            onTap: (x) async {
              setState(() {
                _selectedTab = x;
              });
            },
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.event_note), label: 'Entrenos'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.pool), label: 'Piscinas'),
              BottomNavigationBarItem(
                  icon: Icon(
                    key: Key('profile'),
                    Icons.person,
                    semanticLabel: 'Perfil',
                  ),
                  label: 'Perfil')
              // BottomNavigationBarItem(
              //     icon: Icon(Icons.person_2), label: 'Perfil'),
            ]),
        body: IndexedStack(index: _selectedTab, children: _buildBody));
  }
}
