import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

import 'ThemeNotifier.dart';
import 'package:fitness_tracker/pages/details/details.dart';
import 'package:fitness_tracker/pages/auth/login.dart';
import 'package:fitness_tracker/pages/auth/signup.dart';
import 'package:fitness_tracker/pages/home/home.dart';
import 'package:fitness_tracker/pages/goal/goal_selection.dart';
import 'package:fitness_tracker/pages/goal/weight_goal.dart';
import 'package:fitness_tracker/settings/settings.dart';
import 'package:fitness_tracker/pages/map/map_page.dart';
import 'package:fitness_tracker/pages/running/running_page.dart'; // Import the Running Page

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('es'), Locale('fr')],
      path: 'assets/lang',
      fallbackLocale: const Locale('en'),
      child: ChangeNotifierProvider(
        create: (context) => ThemeNotifier(),
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      title: 'Fitness Tracker',
      theme: themeNotifier.currentTheme,
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/weight_goal': (context) => const WeightGoalPage(),
        '/goal_selection': (context) => const GoalSelectionPage(),
        '/home': (context) => const HomePage(),
        '/settings': (context) => const SettingsPage(),
        '/details': (context) => const DetailsPage(),
        '/map': (context) => const MapPage(),
        '/running': (context) => const RunningPage(), // New route for Running Page
      },
      initialRoute: '/',
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
    );
  }
}
