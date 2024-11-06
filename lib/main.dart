import 'package:fitness_tracker/pages/details/details.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fitness_tracker/pages/auth/login.dart';
import 'package:fitness_tracker/pages/auth/signup.dart';
import 'package:fitness_tracker/pages/home/home.dart';
import 'package:fitness_tracker/pages/goal/goal_selection.dart';
import 'package:fitness_tracker/pages/goal/weight_goal.dart';
import 'package:fitness_tracker/settings/settings.dart';//
import 'package:provider/provider.dart';
import 'ThemeNotifier.dart'; // Import the ThemeNotifier

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeNotifier(), // Provide ThemeNotifier
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context); // Access ThemeNotifier

    return MaterialApp(
      title: 'Fitness Tracker',
      theme: themeNotifier.currentTheme, // Set the theme from ThemeNotifier
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/weight_goal': (context) => const WeightGoalPage(),
        '/goal_selection': (context) => const GoalSelectionPage(),
        '/home': (context) => const HomePage(),
        '/settings': (context) => const SettingsPage(),
        '/details': (context) => const DetailsPage(),

      },
      initialRoute: '/',
    );
  }
}







