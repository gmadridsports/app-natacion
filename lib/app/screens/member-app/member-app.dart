import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gmadrid_natacion/app/screens/member-app/RefreshTrainingWeekEvent.dart';
import 'package:gmadrid_natacion/shared/dependency_injection.dart';
import '../NamedRouteScreen.dart';
import 'calendar-events/calendar_events.dart';
import 'profile/profile.dart';
import 'training-week/training-week.dart';

import 'package:event_bus/event_bus.dart' as LibEventBus;

class MemberApp extends StatefulWidget implements NamedRouteScreen {
  static String get routeName => '/member-app';

  @override
  State<MemberApp> createState() => _MemberAppState();
}

class _MemberAppState extends State<MemberApp> {
  int _selectedTab = 0;

  Widget? _buildBody(int index) {
    switch (index) {
      case 0:
        return TrainingWeek();
      case 1:
        return CalendarEvents();
      case 2:
        return Profile();
    }
  }

  _MemberAppState();

  @override
  void didChangeDependencies() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            if (_selectedTab == 0)
              IconButton(
                  onPressed: () {
                    DependencyInjection()
                        .getInstanceOf<LibEventBus.EventBus>()
                        .fire(RefreshTrainingWeekEvent());
                  },
                  icon: Icon(Icons.refresh))
          ],
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
                  icon: Icon(key: Key('calendar'), Icons.event_note),
                  label: 'Calendario'),
              BottomNavigationBarItem(
                  icon: Icon(
                    key: Key('profile'),
                    Icons.person,
                    semanticLabel: 'Perfil',
                  ),
                  label: 'Perfil')
            ]),
        body: _buildBody(_selectedTab));
  }
}
