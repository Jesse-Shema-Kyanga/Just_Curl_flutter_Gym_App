import 'package:flutter/material.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math';
import '../../helpers/database_helper.dart';
import '../../user_preferences.dart';

class RunningPage extends StatefulWidget {
  const RunningPage({Key? key}) : super(key: key);

  @override
  _RunningPageState createState() => _RunningPageState();
}

class _RunningPageState extends State<RunningPage> {
  final DatabaseHelper _db = DatabaseHelper();
  bool isRunning = false;
  Stopwatch stopwatch = Stopwatch();
  String elapsedTime = '00:00:00';
  Timer? timer;
  double distance = 0.0;
  int calories = 0;
  String pace = '0:00';
  List<Map<String, dynamic>> runningHistory = [];
  Position? lastPosition;
  StreamSubscription<Position>? positionStream;
  StreamSubscription<UserAccelerometerEvent>? _accelerometerSubscription;
  double _stepThreshold = 12.0;
  DateTime? _lastStepTime;
  int steps = 0;

  @override
  void initState() {
    super.initState();
    _loadRunningHistory();
    _createRunningTable();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    await _handleLocationPermission();
  }

  Future<void> _createRunningTable() async {
    await _db.createRunningTable();
  }

  @override
  void dispose() {
    timer?.cancel();
    stopLocationTracking();
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  void initPedometer() {
    _accelerometerSubscription?.cancel();
    _lastStepTime = null;

    _accelerometerSubscription = userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      if (!mounted || !isRunning) return;

      double acceleration = sqrt(
          event.x * event.x +
              event.y * event.y +
              event.z * event.z
      );

      DateTime now = DateTime.now();
      if (_lastStepTime == null) {
        _lastStepTime = now;
      }

      if (acceleration > _stepThreshold &&
          now.difference(_lastStepTime!).inMilliseconds > 250) {
        setState(() {
          steps++;
          _lastStepTime = now;
        });
      }
    });
  }

  Future<void> _loadRunningHistory() async {
    final userEmail = await UserPreferences.getEmail();
    if (userEmail != null) {
      final history = await _db.getRunningHistory(userEmail);
      setState(() {
        runningHistory = history;
      });
    }
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled')),
      );
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied')),
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permissions are permanently denied')),
      );
      return false;
    }
    return true;
  }

  void startLocationTracking() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;

    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      if (lastPosition != null && isRunning) {
        final newDistance = Geolocator.distanceBetween(
          lastPosition!.latitude,
          lastPosition!.longitude,
          position.latitude,
          position.longitude,
        );

        setState(() {
          distance += newDistance / 1000;
          pace = _calculatePace();
          calories = _calculateCalories();
        });
      }
      lastPosition = position;
    });
  }

  void stopLocationTracking() {
    positionStream?.cancel();
    lastPosition = null;
  }

  void startRun() {
    setState(() {
      isRunning = true;
      stopwatch.start();
      timer = Timer.periodic(const Duration(seconds: 1), updateTime);
      startLocationTracking();
      initPedometer();
    });
  }

  void stopRun() {
    setState(() {
      isRunning = false;
      stopwatch.stop();
      timer?.cancel();
      stopLocationTracking();
      _accelerometerSubscription?.cancel();
    });
  }

  void resetRun() {
    setState(() {
      stopwatch.reset();
      elapsedTime = '00:00:00';
      distance = 0.0;
      calories = 0;
      pace = '0:00';
      steps = 0;
      _lastStepTime = null;
    });
  }

  Future<void> _saveSession() async {
    final userEmail = await UserPreferences.getEmail();
    if (userEmail != null) {
      await _db.insertRunningSession({
        'user_email': userEmail,
        'duration': elapsedTime,
        'distance': distance,
        'calories': calories,
        'average_pace': pace,

        'date': DateTime.now().toIso8601String(),
      });

      await _loadRunningHistory();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session saved successfully!')),
      );
    }
  }

  void updateTime(Timer timer) {
    if (stopwatch.isRunning) {
      setState(() {
        elapsedTime = _formatTime(stopwatch.elapsedMilliseconds);
        calories = _calculateCalories();
        pace = _calculatePace();
      });
    }
  }

  String _formatTime(int milliseconds) {
    int hundreds = (milliseconds / 10).truncate();
    int seconds = (hundreds / 100).truncate();
    int minutes = (seconds / 60).truncate();
    int hours = (minutes / 60).truncate();

    String hoursStr = (hours % 60).toString().padLeft(2, '0');
    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');

    return "$hoursStr:$minutesStr:$secondsStr";
  }

  String _calculatePace() {
    if (distance <= 0) return '0:00';

    int totalSeconds = stopwatch.elapsedMilliseconds ~/ 1000;
    if (totalSeconds <= 0) return '0:00';

    double minutesPerKm = totalSeconds / 60 / distance;
    int minutes = minutesPerKm.floor();
    int seconds = ((minutesPerKm - minutes) * 60).round();

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  int _calculateCalories() {
    double met = 7.0;
    if (pace != '0:00') {
      List<String> paceParts = pace.split(':');
      int paceMinutes = int.parse(paceParts[0]);
      if (paceMinutes < 5) met = 9.8;
      else if (paceMinutes < 6) met = 9.0;
      else if (paceMinutes < 7) met = 8.3;
      else if (paceMinutes < 8) met = 7.8;
    }

    double hours = stopwatch.elapsedMilliseconds / (1000 * 60 * 60);
    double weight = 70;

    return ((met * weight * hours) + (steps * 0.04)).round();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTimer(),
            _buildStats(),
            _buildControls(),
            const Divider(height: 32),
            _buildRunningHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            'Running Session',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildTimer() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Text(
        elapsedTime,
        style: const TextStyle(
          fontSize: 60,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
      ),
    );
  }

  Widget _buildStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('Distance', '${distance.toStringAsFixed(2)} km'),
          _buildStatItem('Pace', '$pace /km'),
          _buildStatItem('Steps', steps.toString()),
          _buildStatItem('Calories', calories.toString()),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            onPressed: resetRun,
            backgroundColor: Colors.grey,
            child: const Icon(Icons.refresh),
          ),
          FloatingActionButton(
            onPressed: isRunning ? stopRun : startRun,
            backgroundColor: isRunning ? Colors.red : Colors.green,
            child: Icon(isRunning ? Icons.stop : Icons.play_arrow),
          ),
          if (!isRunning && distance > 0)
            FloatingActionButton(
              onPressed: _saveSession,
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.save),
            ),
        ],
      ),
    );
  }

  Widget _buildRunningHistory() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Running History',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: runningHistory.length,
                itemBuilder: (context, index) {
                  final session = runningHistory[index];
                  return _buildHistoryItem(session);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> session) {
    final date = DateTime.parse(session['date']);
    final formattedDate = '${date.day}/${date.month}/${date.year}';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.directions_run),
        title: Text('${session['distance'].toStringAsFixed(2)} km'),
        subtitle: Text('Duration: ${session['duration']} • Steps: ${session['steps']}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(formattedDate),
            Text('${session['calories']} cal'),
          ],
        ),
      ),
    );
  }
}
