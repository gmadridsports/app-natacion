import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../NamedRouteScreen.dart';
import 'calendar-events/CalendarEvents.dart';
import 'profile/profile.dart';
import 'training-week/training-week.dart';

class MemberApp extends StatefulWidget implements NamedRouteScreen {
  static String get routeName => '/member-app';

  @override
  State<MemberApp> createState() => _MemberAppState();
}

class _MemberAppState extends State<MemberApp> {
  int _selectedTab = 0;
  final _buildBody = const <Widget>[
    TrainingWeek(),
    CalendarEvents(),
    Profile()
  ];

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
                  icon: Icon(Icons.pool), label: 'Entrenos'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.event_note), label: 'Calendario'),
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
