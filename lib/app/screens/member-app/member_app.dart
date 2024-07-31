import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gmadrid_natacion/Context/Natacion/application/RedirectToScreen/update_showing_screen.dart';
import 'package:gmadrid_natacion/Context/Natacion/domain/screen/screen.dart';
import 'package:gmadrid_natacion/app/screens/member-app/RefreshTrainingWeekEvent.dart';
import 'package:gmadrid_natacion/app/screens/member-app/bulletin-board/bulletin_board.dart';
import 'package:gmadrid_natacion/app/screens/member-app/calendar-events/refresh_calendar_events.dart';
import 'package:gmadrid_natacion/app/screens/webpage-content/webpage-content.dart';
import 'package:gmadrid_natacion/shared/dependency_injection.dart';
import '../NamedRouteScreen.dart';
import 'calendar-events/calendar_events.dart';
import 'profile/profile.dart';
import 'training-week/training-week.dart';

import 'package:event_bus/event_bus.dart' as LibEventBus;

class MemberApp extends StatefulWidget implements NamedRouteScreen {
  static String get routeName => MainScreen.memberApp.name;
  final String _initialRoute;

  static final Map<int, String> _tabsRouteNames = {
    0: TrainingWeek.routeName,
    1: CalendarEvents.routeName,
    2: BulletinBoard.routeName,
    3: Profile.routeName
  };

  @override
  State<MemberApp> createState() => _MemberAppState();

  MemberApp(this._initialRoute);
}

class _MemberAppState extends State<MemberApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  static final Map<String, int> _routeTabNumber = {
    TrainingWeek.routeName: 0,
    CalendarEvents.routeName: 1,
    BulletinBoard.routeName: 2,
    Profile.routeName: 3
  };
  static final Map<int, String> _tabNumberRoute = {
    0: TrainingWeek.routeName,
    1: CalendarEvents.routeName,
    2: BulletinBoard.routeName,
    3: Profile.routeName,
    4: WebPageContent.routeName
  };
  String _selectedTabRoute = _tabNumberRoute[0]!;

  Widget? _buildBody() {
    return Navigator(
      key: _navigatorKey,
      initialRoute: widget._initialRoute,
      onGenerateRoute: (RouteSettings settings) {
        generatePageRoute(NamedRouteScreen route) {
          return NoAnimationPageRoute<Widget>(
            builder: (context) {
              return route;
            },
            settings: settings,
          );
        }

        if (settings.name!.startsWith(CalendarEvents.routeName)) {
          return generatePageRoute(const CalendarEvents());
        }

        if (settings.name!.startsWith(BulletinBoard.routeName)) {
          return generatePageRoute(const BulletinBoard());
        }

        if (settings.name!.startsWith(Profile.routeName)) {
          return generatePageRoute(const Profile());
        }

        return generatePageRoute(const TrainingWeek());
      },
    );
  }

  _MemberAppState();

  @override
  void didChangeDependencies() async {}

  @override
  void initState() {
    _selectedTabRoute =
        _tabNumberRoute[_routeTabNumber[widget._initialRoute] ?? 0] ??
            TrainingWeek.routeName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            if (_selectedTabRoute == TrainingWeek.routeName ||
                _selectedTabRoute == CalendarEvents.routeName)
              IconButton(
                  onPressed: () {
                    DependencyInjection()
                        .getInstanceOf<LibEventBus.EventBus>()
                        .fire(_selectedTabRoute == 0
                            ? RefreshTrainingWeekEvent()
                            : RefreshCalendarEvents());
                  },
                  icon: Icon(Icons.refresh))
          ],
          title: Text('GMadrid Natación'),
        ),
        bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _routeTabNumber[_selectedTabRoute] ?? 0,
            onTap: (x) async {
              setState(() {
                _selectedTabRoute = _tabNumberRoute[x] ?? _tabNumberRoute[0]!;
                UpdateShowingScreen()(Screen.fromString(_selectedTabRoute));
              });
              _navigatorKey.currentState!.pushReplacementNamed(
                  MemberApp._tabsRouteNames[x] ?? TrainingWeek.routeName);
            },
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.pool), label: 'Entrenos'),
              BottomNavigationBarItem(
                  icon: Icon(key: Key('calendar'), Icons.event_note),
                  label: 'Calendario'),
              BottomNavigationBarItem(
                  icon: Icon(key: Key('bulletin'), Icons.announcement),
                  label: 'Avisos'),
              BottomNavigationBarItem(
                  icon: Icon(
                    key: Key('profile'),
                    Icons.person,
                    semanticLabel: 'Perfil',
                  ),
                  label: 'Perfil'),
            ]),
        body: _buildBody());
  }
}

class NoAnimationPageRoute<T> extends MaterialPageRoute<T> {
  NoAnimationPageRoute({
    required Widget Function(BuildContext) builder,
    RouteSettings? settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) : super(
          builder: builder,
          settings: settings,
          maintainState: maintainState,
          fullscreenDialog: fullscreenDialog,
        );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}
