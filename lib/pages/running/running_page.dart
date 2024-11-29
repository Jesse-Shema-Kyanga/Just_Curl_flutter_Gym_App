import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math';

class RunningPage extends StatefulWidget {
  const RunningPage({Key? key}) : super(key: key);

  @override
  _RunningPageState createState() => _RunningPageState();
}

class _RunningPageState extends State<RunningPage> {
  // Compass Variables
  double heading = 0.0; // Compass heading
  bool isCompassSupported = true;

  // Step Counter Variables
  int stepCount = 0;
  double lastAcceleration = 0.0;
  double dynamicThreshold = 2.5; // Adaptive threshold
  double stepLength = 0.762; // Average step length in meters
  double distanceTraveled = 0.0;
  final List<double> accelerationHistory = [];
  DateTime lastStepTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _startCompass();
    _startStepCounting();
  }

  // Compass Initialization
  void _startCompass() {
    FlutterCompass.events!.listen((event) {
      if (event.heading == null) {
        setState(() {
          isCompassSupported = false;
        });
        return;
      }
      setState(() {
        heading = event.heading!;
      });
    });
  }

  // Step Counter Initialization
  void _startStepCounting() {
    accelerometerEvents.listen((AccelerometerEvent event) {
      double currentAcceleration = sqrt(
          event.x * event.x + event.y * event.y + event.z * event.z);

      // Update acceleration history
      if (accelerationHistory.length >= 10) {
        accelerationHistory.removeAt(0);
      }
      accelerationHistory.add(currentAcceleration);

      // Calculate smoothed acceleration and adaptive threshold
      double smoothedAcceleration = accelerationHistory.reduce((a, b) => a + b) / accelerationHistory.length;
      double adjustedThreshold = dynamicThreshold;

      // Detect steps based on smoothed acceleration
      if ((smoothedAcceleration - lastAcceleration).abs() > adjustedThreshold) {
        DateTime now = DateTime.now();

        // Ensure at least 300ms between steps
        if (now.difference(lastStepTime).inMilliseconds > 300) {
          setState(() {
            stepCount++;
            lastStepTime = now;
            distanceTraveled = stepCount * stepLength;
          });
        }
      }
      lastAcceleration = smoothedAcceleration;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Running Tracker'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // Compass Display
            Column(
              children: [
                const Text(
                  'Compass',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                isCompassSupported
                    ? SizedBox(
                  width: 150,
                  height: 150,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Transform.rotate(
                        angle: heading * pi / 180, // Rotate compass
                        child: const Icon(
                          Icons.navigation,
                          size: 80,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                )
                    : const Text(
                  'Compass not supported on this device',
                  style: TextStyle(color: Colors.red),
                ),
                isCompassSupported
                    ? Text(
                  '${heading.toStringAsFixed(2)}°',
                  style: const TextStyle(fontSize: 20),
                )
                    : Container(),
              ],
            ),

            const Divider(height: 40),

            // Step Counter Display
            Column(
              children: [
                const Text(
                  'Steps & Distance',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'Steps: $stepCount',
                  style: const TextStyle(fontSize: 20),
                ),
                Text(
                  'Distance: ${distanceTraveled.toStringAsFixed(2)} m',
                  style: const TextStyle(fontSize: 20),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
