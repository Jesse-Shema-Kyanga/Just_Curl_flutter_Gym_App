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
  // Step Counter Variables
  int stepCount = 0;
  double lastAcceleration = 0.0;
  double dynamicThreshold = 1.8; // Optimized threshold
  double stepLength = 0.65; // Average step length in meters
  double distanceTraveled = 0.0;
  final List<double> accelerationHistory = List.filled(5, 0.0);
  DateTime lastStepTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _startStepCounting();
  }

  void _startStepCounting() {
    accelerometerEvents.listen((AccelerometerEvent event) {
      double currentAcceleration = sqrt(
          event.x * event.x + event.y * event.y + event.z * event.z);

      // Shift values in acceleration history
      for (int i = 0; i < accelerationHistory.length - 1; i++) {
        accelerationHistory[i] = accelerationHistory[i + 1];
      }
      accelerationHistory[accelerationHistory.length - 1] = currentAcceleration;

      double smoothedAcceleration = accelerationHistory.reduce((a, b) => a + b) /
          accelerationHistory.length;

      if ((currentAcceleration > smoothedAcceleration + dynamicThreshold) &&
          (currentAcceleration > lastAcceleration)) {
        DateTime now = DateTime.now();
        if (now.difference(lastStepTime).inMilliseconds > 250) {
          setState(() {
            stepCount++;
            distanceTraveled = stepCount * stepLength;
            lastStepTime = now;
          });
        }
      }
      lastAcceleration = currentAcceleration;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Running Tracker'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Expanded(
            child:// In the build method, update the StreamBuilder section:
            StreamBuilder<CompassEvent>(
              stream: FlutterCompass.events,
              builder: (context, snapshot) {
                // First check if device has sensors
                if (!snapshot.hasData) {
                  return const Center(
                    child: Text(
                      "Calibrating sensors...",
                      style: TextStyle(fontSize: 20),
                    ),
                  );
                }

                double? heading = snapshot.data!.heading;

                if (heading != null) {
                  return Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Transform.rotate(
                          angle: (-heading) * (pi / 180),
                          child: Image.asset(
                            'assets/compass.jpg',  // Updated asset path
                            width: 300,
                            height: 300,
                          ),
                        ),
                        Container(
                          width: 4,
                          height: 150,
                          color: Colors.red,
                        ),
                        Positioned(
                          bottom: 0,
                          child: Text(
                            '${heading.toStringAsFixed(0)}°',
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return const Center(
                    child: Text(
                      "Move your device in a figure 8 pattern",
                      style: TextStyle(fontSize: 20),
                    ),
                  );
                }
              },
            )

          ),
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Activity Tracking',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
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
            ),
          ),
        ],
      ),
    );
  }
}
