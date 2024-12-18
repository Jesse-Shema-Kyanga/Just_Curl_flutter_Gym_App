import 'dart:math';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController _mapController;
  Location _location = Location();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  LatLng? _userLocation;
  LatLng _gymLocation = LatLng(0.0, 0.0); // Default gym coordinates
  double _radius = 0.0; // Default geofence radius

  @override
  void initState() {
    super.initState();
    _loadConfig();
    _getUserLocation();
    _initializeNotifications();
  }

  Future<void> _loadConfig() async {
    // Load the gym location and radius from the config.json file
    String configString = await rootBundle.loadString('assets/config.json');
    Map<String, dynamic> config = json.decode(configString);

    setState(() {
      _gymLocation = LatLng(config['gym_latitude'], config['gym_longitude']);
      _radius = config['geofence_radius'];
    });
  }

  Future<void> _initializeNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final settings = InitializationSettings(android: android);
    await flutterLocalNotificationsPlugin.initialize(settings);
  }

  Future<void> _getUserLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) return;
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) return;
    }

    LocationData locationData = await _location.getLocation();
    setState(() {
      _userLocation = LatLng(locationData.latitude!, locationData.longitude!);
      _checkGeofence(_userLocation!);
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _checkGeofence(LatLng userLocation) {
    double distance = _calculateDistance(userLocation, _gymLocation);
    if (distance <= _radius) {
      _triggerNotification();
    }
  }

  double _calculateDistance(LatLng start, LatLng end) {
    var p = 0.017453292519943295; // Pi / 180
    var c = cos;
    var a = 0.5 - c((end.latitude - start.latitude) * p) / 2 +
        c(start.latitude * p) * c(end.latitude * p) *
            (1 - c((end.longitude - start.longitude) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R = 12742 km
  }

  Future<void> _triggerNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      importance: Importance.high,
      priority: Priority.high,
    );
    const platformDetails = NotificationDetails(android: androidDetails);
    await flutterLocalNotificationsPlugin.show(
      0,
      'You have arrived at the gym',
      'Welcome to your gym! Start your workout!',
      platformDetails,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
        backgroundColor: Colors.blue,
      ),
      body: _userLocation == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _userLocation!,
          zoom: 15.0,
        ),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        markers: {
          Marker(
            markerId: MarkerId('user'),
            position: _userLocation!,
            infoWindow: InfoWindow(title: 'Your Location'),
          ),
          Marker(
            markerId: MarkerId('gym'),
            position: _gymLocation,
            infoWindow: InfoWindow(title: 'Gym Location'),
          ),
        },
        circles: {
          Circle(
            circleId: CircleId('gym_zone'),
            center: _gymLocation,
            radius: _radius,
            fillColor: Colors.blue.withOpacity(0.3),
            strokeColor: Colors.blue,
            strokeWidth: 2,
          ),
        },
      ),
    );
  }

}
