import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class WeightGoalPage extends StatefulWidget {
  const WeightGoalPage({Key? key}) : super(key: key);

  @override
  _WeightGoalPageState createState() => _WeightGoalPageState();
}

class _WeightGoalPageState extends State<WeightGoalPage> {
  double _goalWeight = 70.0; // Default weight goal

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('setWeightGoal').tr(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'setYourWeightGoal',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ).tr(),
            const SizedBox(height: 24),
            Slider(
              value: _goalWeight,
              min: 30.0, // Minimum weight
              max: 150.0, // Maximum weight
              divisions: 120, // Number of divisions
              label: _goalWeight.round().toString(),
              onChanged: (double value) {
                setState(() {
                  _goalWeight = value;
                });
              },
            ),
            Text(
              'goalWeight'.tr(namedArgs: {'weight': _goalWeight.round().toString()}),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _saveWeightGoal,
              child: const Text('saveAndContinue').tr(),
            ),
          ],
        ),
      ),
    );
  }

  void _saveWeightGoal() {
    // Logic to save the weight goal, if using SQLite you can add the goal to the database
    print('Goal Weight: $_goalWeight kg');

    // Show confirmation (optional)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('weightGoalSet'.tr(namedArgs: {'weight': _goalWeight.round().toString()}))),
    );

    // Navigate to the next page (goal selection or home page)
    Navigator.pushReplacementNamed(context, '/goal_selection');
  }
}
