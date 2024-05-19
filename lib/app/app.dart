import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gmadrid_natacion/Context/Natacion/application/RedirectToScreen/update_showing_screen.dart';
import 'package:gmadrid_natacion/Context/Natacion/domain/user/ListenedEvents/UserAppUsagePermissionsChanged.dart';
import 'package:gmadrid_natacion/Context/Natacion/domain/user/user_logged_in_event.dart';
import 'package:gmadrid_natacion/Context/Natacion/infrastructure/navigation_request/shared_preferences_navigation_request.dart';
import 'package:gmadrid_natacion/app/screens/NamedRouteScreen.dart';
import 'package:gmadrid_natacion/shared/dependency_injection.dart';

import 'package:event_bus/event_bus.dart' as LibEventBus;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart';
import '../Context/Natacion/domain/navigation_request/navigation_request.dart';
import '../Context/Natacion/domain/screen/ChangedCurrentScreenDomainEvent.dart';
import '../Context/Natacion/domain/screen/screen.dart';
import '../Context/Natacion/domain/user/user_login_event.dart';
import '../Context/Natacion/infrastructure/app_interface/queries/GetSessionUser.dart';
import '../Context/Natacion/infrastructure/supabase_user_status_listener.dart';
import '../Context/Shared/infrastructure/Bus/Event/LibEventBusEventBus.dart';
import '../conf/dependency_injections.dart';
import './screens/splash-screen/splash-screen.dart';
import '../shared/infrastructure/notification_service.dart';
import 'screens/login/login.dart';
import 'screens/member-app/member_app.dart';
import 'screens/waiting-approval/waiting-approval.dart';

@pragma('vm:entry-point')
Future<void> _handleOpenAppViaNotification(RemoteMessage? message) async {
  try {
    if (message == null) {
      return;
    }

    final repo = SharedPreferencesNavigationRequestRepository();
    await repo.saveNavigationRequest(NavigationRequest.fromRaw({
      NavigationRequest.requestScreenFullPathKey:
          message.data[NavigationRequest.requestScreenFullPathKey],
      NavigationRequest.requestTypeKey:
          message.data[NavigationRequest.requestTypeKey]
    }));
  } catch (e, stack) {
    FirebaseCrashlytics.instance.recordError(e, stack);
  }
}

Future<bool> runAppWithOptions({
  String envName = 'prod',
  Client? httpClient,
  Function()? appConfig,
}) async {
  await dotenv.load(fileName: 'assets/.$envName.env', mergeWith: {});

  await Supabase.initialize(
    url: dotenv.get('SUPABASE_URL'),
    anonKey: dotenv.get('SUPABASE_ANON_KEY', fallback: ''),
    debug: false,
    httpClient: httpClient,
  );

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  try {
    String? token = await messaging.getToken();

    if (kDebugMode) {
      print('Registration Token=$token');
      print(
          'Supabase token=${Supabase.instance.client.auth.currentSession?.accessToken}');
    }
  } catch (e) {
    FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
  }

  (appConfig ??
      () {
        DependencyInjection(instances: dependencyInjectionInstances());
      })();

  final messageFromOpenedNotification =
      await FirebaseMessaging.instance.getInitialMessage();
  _handleOpenAppViaNotification(messageFromOpenedNotification);
  FirebaseMessaging.onBackgroundMessage(_handleOpenAppViaNotification);
  FirebaseMessaging.onMessageOpenedApp.listen(_handleOpenAppViaNotification);

  runApp(App());

  return true;
}

class App extends StatefulWidget {
  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  final GlobalKey<NavigatorState> _navigator = GlobalKey<NavigatorState>();
  late StreamSubscription _firebaseTokenRefreshSubscription;
  late final SupabaseUserStatusListener _supabaseUserStatusListener;

  _AppState() {
    _supabaseUserStatusListener = SupabaseUserStatusListener();
    _initializeGlobalAppEventListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      if (state == AppLifecycleState.resumed) {
        _supabaseUserStatusListener.refresh();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _initializeGlobalAppEventListeners() async {
    await DependencyInjection().getInstanceOf<NotificationService>().init();

    DependencyInjection()
        .getInstanceOf<LibEventBus.EventBus>()
        .on<AppEventType>()
        .listen((event) async {
      switch (event.payload.eventName) {
        case ChangedCurrentScreenDomainEvent.EVENT_NAME:
          final screenEvent = event.payload as ChangedCurrentScreenDomainEvent;
          if (screenEvent.changedFromUi) {
            return;
          }
          _navigator.currentState
              ?.pushReplacementNamed(screenEvent.newScreenPath);
          break;
        case UserAppUsagePermissionsChanged.EVENT_NAME:
          final userPermissions =
              event.payload as UserAppUsagePermissionsChanged;

          if (userPermissions.canUseApp) {
            DependencyInjection()
                .getInstanceOf<NotificationService>()
                .sendNotification('Membresía aprobada',
                    '¡Te damos la bienvenida a GMadrid! 🏊🏼');
          }
          break;
        case UserAlreadyLoggedInEvent.EVENT_NAME:
          // todo https://trello.com/c/qE6KAeau move push notification logics to the context
          try {
            final sessionId = JwtDecoder.decode(Supabase
                    .instance.client.auth.currentSession?.accessToken
                    .toString() ??
                '')['session_id'];
            final fcmToken = await FirebaseMessaging.instance.getToken();

            await Supabase.instance.client.from('notification_tokens').upsert({
              'user_id': Supabase.instance.client.auth.currentUser?.id,
              'session_id': sessionId,
              'token': fcmToken,
            });

            _firebaseTokenRefreshSubscription = FirebaseMessaging
                .instance.onTokenRefresh
                .listen((newToken) async {
              final user = await GetSessionUser()();
              if (!user.isLogged) {
                return;
              }

              await Supabase.instance.client
                  .from('notification_tokens')
                  .upsert({
                'user_id': Supabase.instance.client.auth.currentUser?.id,
                'session_id': sessionId,
                'token': newToken,
              });
            });
          } catch (e) {
            FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
          }
          break;
        case UserLoginEvent.EVENT_NAME:
          try {
            final sessionId = JwtDecoder.decode(Supabase
                    .instance.client.auth.currentSession?.accessToken
                    .toString() ??
                '')['session_id'];
            final fcmToken = await FirebaseMessaging.instance.getToken();

            await Supabase.instance.client.from('notification_tokens').upsert({
              'user_id': Supabase.instance.client.auth.currentUser?.id,
              'session_id': sessionId,
              'token': fcmToken,
            });

            _firebaseTokenRefreshSubscription = FirebaseMessaging
                .instance.onTokenRefresh
                .listen((newToken) async {
              final user = await GetSessionUser()();
              if (!user.isLogged) {
                return;
              }

              await Supabase.instance.client
                  .from('notification_tokens')
                  .upsert({
                'user_id': Supabase.instance.client.auth.currentUser?.id,
                'session_id': sessionId,
                'token': newToken,
              });
            });
          } catch (e) {
            FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
          }

        default:
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GMadrid Natación',
      navigatorKey: _navigator,
      theme: ThemeData(
        useMaterial3: false,
      ),
      onGenerateRoute: (settings) {
        generatePageRoute(NamedRouteScreen route) {
          return MaterialPageRoute<Widget>(
            builder: (context) {
              return route;
            },
            settings: settings,
          );
        }

        if (settings.name == null || settings.name == '/') {
          UpdateShowingScreen()(Screen.fromString(MainScreen.splash.name));
          return generatePageRoute(const SplashScreen());
        }

        final routeToNavigate = settings.name as String;
        UpdateShowingScreen()(Screen.fromString(routeToNavigate));

        if (routeToNavigate.startsWith(WaitingApproval.routeName)) {
          return generatePageRoute(WaitingApproval());
        }

        if (routeToNavigate.startsWith(MemberApp.routeName)) {
          return generatePageRoute(MemberApp(routeToNavigate));
        }

        if (routeToNavigate.startsWith(SplashScreen.routeName)) {
          return generatePageRoute(const SplashScreen());
        }

        if (routeToNavigate.startsWith(Login.routeName)) {
          return generatePageRoute(const Login());
        }
        throw Exception('Unknown route: ${settings.name}');
      },
    );
  }
}
