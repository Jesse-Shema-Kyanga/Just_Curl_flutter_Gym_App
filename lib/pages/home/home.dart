import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fitness_tracker/pages/auth/google_signin_api.dart';
import 'package:fitness_tracker/pages/details/details.dart';
import 'package:fitness_tracker/pages/home/widgets/activity.dart';
import 'package:fitness_tracker/pages/home/widgets/current.dart';
import 'package:fitness_tracker/pages/home/widgets/header.dart';
import 'package:fitness_tracker/widgets/bottom_navigation.dart';
import '../../helpers/database_helper.dart';
import '../../user_preferences.dart';
import '../running/running_page.dart';
import '../exercise/exercise_logging_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseHelper _db = DatabaseHelper();
  String username = '';
  String workoutGoal = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userEmail = await UserPreferences.getEmail();
    if (userEmail != null) {
      final userProfile = await _db.getUserProfile(userEmail);
      if (userProfile != null) {
        setState(() {
          username = userProfile['name'] ?? '';
          workoutGoal = userProfile['workout_goal'] ?? '';
        });
      }
    }
  }

  Future<void> _handleLogout() async {
    try {
      // Clear all user data in parallel
      await Future.wait([
        UserPreferences.clearLoginStatus(),
        UserPreferences.setEmail(''),
        GoogleSignInApi.logout(),
      ]);

      // Add a confirmation dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Logging Out'),
            content: const Text('Are you sure you want to log out?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                        (route) => false,
                  );
                },
                child: const Text('Yes'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('No'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: $e')),
      );
    }
  }


  List<Map<String, dynamic>> _getRecommendations() {
    switch (workoutGoal.toLowerCase()) {
      case 'weight loss':
        return [
          {
            'title': 'HIIT Cardio',
            'description': '30 min high intensity workout',
            'icon': FontAwesomeIcons.personRunning,
          },
          {
            'title': 'Diet Tips',
            'description': 'Calorie deficit guidelines',
            'icon': FontAwesomeIcons.utensils,
          },
        ];
      case 'muscle gain':
        return [
          {
            'title': 'Strength Training',
            'description': 'Upper body workout',
            'icon': FontAwesomeIcons.dumbbell,
          },
          {
            'title': 'Protein Guide',
            'description': 'Nutrition for muscle growth',
            'icon': FontAwesomeIcons.egg,
          },
        ];
      default:
        return [
          {
            'title': 'Daily Workout',
            'description': 'Full body routine',
            'icon': FontAwesomeIcons.personRunning,
          },
          {
            'title': 'Cardio Session',
            'description': '20 min cardio workout',
            'icon': FontAwesomeIcons.heartPulse,
          },
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final recommendations = _getRecommendations();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fitness Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            AppHeader(userName: username),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Goal: ${workoutGoal.isEmpty ? "Not set" : workoutGoal}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Recommended For You',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recommendations.length,
                    itemBuilder: (context, index) {
                      final recommendation = recommendations[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ListTile(
                          leading: FaIcon(
                            recommendation['icon'] as IconData,
                            color: Theme.of(context).primaryColor,
                            size: 24,
                          ),
                          title: Text(recommendation['title'] as String),
                          subtitle: Text(recommendation['description'] as String),
                          onTap: () => _handleRecommendationTap(recommendation),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            CurrentPrograms(),
            RecentActivities(),
            _buildQuickStats(),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DetailsPage()),
                );
              },
              child: const Text('View Details'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigation(),
    );
  }

  Widget _buildQuickStats() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Stats',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard('Today\'s Steps', '0', FontAwesomeIcons.personWalking),
              _buildStatCard('Workouts This Week', '0', FontAwesomeIcons.dumbbell),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            FaIcon(icon, size: 24, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            Text(value, style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
    );
  }

  void _handleRecommendationTap(Map<String, dynamic> recommendation) {
    switch (recommendation['title']) {
      case 'HIIT Cardio':
      case 'Cardio Session':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RunningPage()),
        );
        break;
      case 'Strength Training':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ExerciseLoggingPage()),
        );
        break;
      case 'Diet Tips':
      case 'Protein Guide':
        _showNutritionDialog(recommendation['title']);
        break;
      default:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ExerciseLoggingPage()),
        );
    }
  }

  void _showNutritionDialog(String title) {
    final String content = title == 'Diet Tips'
        ? 'Focus on maintaining a caloric deficit through balanced meals and portion control.'
        : 'Consume 1.6-2.2g of protein per kg of body weight to support muscle growth.';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
