import 'package:flutter/material.dart';
import '../../helpers/database_helper.dart';

class GoalSelectionPage extends StatefulWidget {
  final String userEmail;
  const GoalSelectionPage({Key? key, required this.userEmail}) : super(key: key);

  @override
  _GoalSelectionPageState createState() => _GoalSelectionPageState();
}

class _GoalSelectionPageState extends State<GoalSelectionPage> {
  String _selectedGoal = 'Gain Muscle';

  final List<String> _goals = [
    'Gain Muscle',
    'Lose Fat',
    'Improve Cardio',
  ];

  void _saveWorkoutGoal() async {
    print('Saving workout goal: $_selectedGoal');
    await DatabaseHelper().updateUserProfile(
      widget.userEmail,
      workoutGoal: _selectedGoal,
    );
    print('Goal saved successfully');

    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Workout Goal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Select Your Workout Goal',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
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
              child: const Text('Finish'),
            ),
          ],
        ),
      ),
    );
  }
}
