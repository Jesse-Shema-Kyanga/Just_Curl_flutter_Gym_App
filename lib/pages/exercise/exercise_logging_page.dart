import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../helpers/database_helper.dart';
import '../../user_preferences.dart';

class ExerciseLoggingPage extends StatefulWidget {
  const ExerciseLoggingPage({Key? key}) : super(key: key);

  @override
  _ExerciseLoggingPageState createState() => _ExerciseLoggingPageState();
}

class _ExerciseLoggingPageState extends State<ExerciseLoggingPage> {
  final DatabaseHelper _db = DatabaseHelper();
  String? userEmail;
  List<Map<String, dynamic>> exerciseHistory = [];

  final List<String> exerciseCategories = [
    'Chest', 'Back', 'Legs', 'Shoulders', 'Arms', 'Core'
  ];

  final Map<String, List<String>> exercises = {
    'Chest': ['Bench Press', 'Push-Ups', 'Dumbbell Flyes'],
    'Back': ['Pull-Ups', 'Rows', 'Lat Pulldowns'],
    'Legs': ['Squats', 'Deadlifts', 'Lunges'],
    'Shoulders': ['Overhead Press', 'Lateral Raises', 'Front Raises'],
    'Arms': ['Bicep Curls', 'Tricep Extensions', 'Hammer Curls'],
    'Core': ['Planks', 'Crunches', 'Russian Twists']
  };

  String selectedCategory = 'Chest';

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
    _loadExerciseHistory();
  }

  Future<void> _loadUserEmail() async {
    userEmail = await UserPreferences.getEmail();
    setState(() {});
  }

  Future<void> _loadExerciseHistory() async {
    final email = await UserPreferences.getEmail();
    if (email != null) {
      final history = await _db.getExerciseLogs(email);
      setState(() {
        exerciseHistory = history;
      });
    }
  }

  Widget _buildCategorySelector() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: exerciseCategories.length,
        itemBuilder: (context, index) {
          final category = exerciseCategories[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(category),
              selected: selectedCategory == category,
              onSelected: (selected) {
                setState(() {
                  selectedCategory = category;
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildExerciseList() {
    return Expanded(
      child: ListView.builder(
        itemCount: exercises[selectedCategory]?.length ?? 0,
        itemBuilder: (context, index) {
          final exercise = exercises[selectedCategory]![index];
          return ListTile(
            title: Text(exercise),
            trailing: IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => _showLogExerciseDialog(exercise),
            ),
            onTap: () => _showLogExerciseDialog(exercise),
          );
        },
      ),
    );
  }

  Widget _buildExerciseHistory() {
    return ListView.builder(
      itemCount: exerciseHistory.length,
      itemBuilder: (context, index) {
        final log = exerciseHistory[index];
        final date = DateTime.parse(log['date']).toLocal();
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            title: Text(log['exercise_name']),
            subtitle: Text(
              '${log['weight']}kg × ${log['reps']} reps × ${log['sets']} sets\n${DateFormat('MMM d, y').format(date)}',
            ),
          ),
        );
      },
    );
  }

  Future<void> _showLogExerciseDialog(String exerciseName) async {
    final weightController = TextEditingController();
    final repsController = TextEditingController();
    final setsController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(exerciseName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'weight'.tr(),
                suffixText: 'kg',
              ),
            ),
            TextField(
              controller: repsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'reps'.tr(),
              ),
            ),
            TextField(
              controller: setsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'sets'.tr(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              if (weightController.text.isNotEmpty &&
                  repsController.text.isNotEmpty &&
                  setsController.text.isNotEmpty) {
                _saveExerciseLog(
                  exerciseName,
                  double.parse(weightController.text),
                  int.parse(repsController.text),
                  int.parse(setsController.text),
                );
              }
              Navigator.pop(context);
            },
            child: Text('save'.tr()),
          ),
        ],
      ),
    );
  }

  Future<void> _saveExerciseLog(String exercise, double weight, int reps, int sets) async {
    if (userEmail != null) {
      await _db.insertExerciseLog({
        'user_email': userEmail,
        'exercise_name': exercise,
        'weight': weight,
        'reps': reps,
        'sets': sets,
        'date': DateTime.now().toIso8601String(),
      });

      _loadExerciseHistory();  // Refresh history after saving

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('exerciseLogged'.tr())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('exerciseLogging'.tr()),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Log Exercise'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Column(
              children: [
                _buildCategorySelector(),
                _buildExerciseList(),
              ],
            ),
            _buildExerciseHistory(),
          ],
        ),
      ),
    );
  }
}
