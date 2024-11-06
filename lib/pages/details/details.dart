import 'package:fitness_tracker/pages/details/widgets/stats.dart';
import 'package:fitness_tracker/pages/details/widgets/appbar.dart';
import 'package:fitness_tracker/pages/details/widgets/graph.dart';
import 'package:fitness_tracker/pages/details/widgets/info.dart' hide Stats;
import 'package:fitness_tracker/pages/details/widgets/steps.dart';
import 'package:fitness_tracker/widgets/bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import '../../ThemeNotifier.dart'; // Adjust as necessary based on your file structure // Adjust as necessary based on your file structure


class DetailsPage extends StatelessWidget {
  const DetailsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context); // Access ThemeNotifier

    return Scaffold(
      backgroundColor: themeNotifier.currentTheme.scaffoldBackgroundColor, // Set background color
      appBar: MainAppBar(appBar: AppBar()),
      body: Column(
        children: [
          // Dates(),
          Steps(),
          Graph(),
          Info(),
          Divider(height: 30),
          Stats(),
          SizedBox(height: 30),
          BottomNavigation(),
        ],
      ),
    );
  }
}

