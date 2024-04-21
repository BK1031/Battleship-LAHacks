import 'package:battleship_lahacks/firebase_options.dart';
import 'package:battleship_lahacks/pages/auth/auth_checker_page.dart';
import 'package:battleship_lahacks/pages/auth/login_page.dart';
import 'package:battleship_lahacks/pages/auth/register_page.dart';
import 'package:battleship_lahacks/pages/game/create_game_page.dart';
import 'package:battleship_lahacks/pages/home_page.dart';
import 'package:battleship_lahacks/utils/config.dart';
import 'package:battleship_lahacks/utils/logger.dart';
import 'package:battleship_lahacks/utils/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
    return const Scaffold(
        body: Center(
            child: Text("Unexpected error. See log for details.")));
  };

  await dotenv.load(fileName: ".env");
  MAPBOX_PUBLIC_TOKEN = dotenv.env['MAPBOX_PUBLIC_TOKEN']!;
  MAPBOX_ACCESS_TOKEN = dotenv.env['MAPBOX_ACCESS_TOKEN']!;
  ONESIGNAL_TOKEN = dotenv.env['ONESIGNAL_TOKEN']!;

  prefs = await SharedPreferences.getInstance();

  log("Battleship v${appVersion.toString()} – ${appVersion.getVersionCode()}");
  FirebaseApp app = await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  log("Initialized default app $app");

  OneSignal.initialize(ONESIGNAL_TOKEN);

// The promptForPushNotificationsWithUserResponse function will show the iOS or Android push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
  OneSignal.Notifications.requestPermission(true);

  // ROUTE DEFINITIONS
  router.define("/", handler: Handler(handlerFunc: (BuildContext? context, Map<String, dynamic>? params) {
    return const Scaffold();
  }));

  router.define("/check-auth", handler: Handler(handlerFunc: (BuildContext? context, Map<String, dynamic>? params) {
    return const AuthCheckerPage();
  }));
  router.define("/register", handler: Handler(handlerFunc: (BuildContext? context, Map<String, dynamic>? params) {
    return const RegisterPage();
  }));
  router.define("/login", handler: Handler(handlerFunc: (BuildContext? context, Map<String, dynamic>? params) {
    return const LoginPage();
  }));

  router.define("/home", handler: Handler(handlerFunc: (BuildContext? context, Map<String, dynamic>? params) {
    return const HomePage();
  }));

  router.define("/game/create", handler: Handler(handlerFunc: (BuildContext? context, Map<String, dynamic>? params) {
    return const CreateGamePage();
  }));

  runApp(MaterialApp(
    title: "Battleship",
    initialRoute: "/check-auth",
    onGenerateRoute: router.generator,
    theme: darkTheme,
    darkTheme: darkTheme,
    debugShowCheckedModeBanner: false,
    navigatorObservers: [
      routeObserver,
    ],
  ),);
}