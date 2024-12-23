import 'package:flutter/material.dart';
import '../../helpers/database_helper.dart';
import 'goal_selection.dart';

class WeightGoalPage extends StatefulWidget {
  final String userEmail;
  const WeightGoalPage({Key? key, required this.userEmail}) : super(key: key);

  @override
  _WeightGoalPageState createState() => _WeightGoalPageState();
}

class _WeightGoalPageState extends State<WeightGoalPage> {
  double _goalWeight = 70.0;
  double _currentWeight = 70.0;

  void _saveWeightGoal() async {
    print('Saving weight goals - Current: $_currentWeight, Goal: $_goalWeight');
    await DatabaseHelper().updateUserProfile(
      widget.userEmail,
      weightGoal: _goalWeight,
      currentWeight: _currentWeight,
    );

    final profile = await DatabaseHelper().getUserProfile(widget.userEmail);
    print('Updated profile: $profile');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Weight goals saved successfully!')),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => GoalSelectionPage(userEmail: widget.userEmail),  // Then to workout goal
      ),
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Weight Goal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Set Your Current Weight',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Slider(
              value: _currentWeight,
              min: 30.0,
              max: 150.0,
              divisions: 120,
              label: _currentWeight.round().toString(),
              onChanged: (double value) {
                setState(() {
                  _currentWeight = value;
                });
              },
            ),
            Text(
              'Current Weight: ${_currentWeight.round()} kg',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 40),
            const Text(
              'Set Your Weight Goal',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Slider(
              value: _goalWeight,
              min: 30.0,
              max: 150.0,
              divisions: 120,
              label: _goalWeight.round().toString(),
              onChanged: (double value) {
                setState(() {
                  _goalWeight = value;
                });
              },
            ),
            Text(
              'Goal Weight: ${_goalWeight.round()} kg',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _saveWeightGoal,
              child: const Text('Save and Continue'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
