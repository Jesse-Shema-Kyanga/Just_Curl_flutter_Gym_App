import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class GoalSelectionPage extends StatefulWidget {
  const GoalSelectionPage({Key? key}) : super(key: key);

  @override
  _GoalSelectionPageState createState() => _GoalSelectionPageState();
}

class _GoalSelectionPageState extends State<GoalSelectionPage> {
  String _selectedGoal = 'gainMuscle'.tr(); // Default workout goal

  final List<String> _goals = [
    'gainMuscle'.tr(),
    'loseFat'.tr(),
    'improveCardio'.tr(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('selectWorkoutGoal').tr(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'selectYourWorkoutGoal',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ).tr(),
            const SizedBox(height: 24),
            ..._goals.map((goal) => RadioListTile<String>(
              title: Text(goal),
              value: goal,
              groupValue: _selectedGoal,
              onChanged: (value) {
                setState(() {
                  _selectedGoal = value ?? _selectedGoal;
                });
              },
            )),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _saveWorkoutGoal,
              child: const Text('finish').tr(),
            ),
          ],
        ),
      ),
    );
  }

  void _saveWorkoutGoal() {
    // Logic to save the selected workout goal
    print('Selected Workout Goal: $_selectedGoal');

    // Show confirmation (optional)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('workoutGoalSet'.tr(namedArgs: {'goal': _selectedGoal}))),
    );

    // Navigate to the home page after finishing goal selection
    Navigator.pushReplacementNamed(context, '/home');
  }
}
