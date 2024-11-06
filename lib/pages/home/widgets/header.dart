import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../user_preferences.dart';


class AppHeader extends StatefulWidget {
  const AppHeader({Key? key}) : super(key: key);

  @override
  _AppHeaderState createState() => _AppHeaderState();
}

class _AppHeaderState extends State<AppHeader> {
  String profileImagePath = 'assets/profile.jpg'; // Default profile image path

  @override
  void initState() {
    super.initState();
    _loadProfilePicture(); // Load profile picture on initialization
  }

  Future<void> _loadProfilePicture() async {
    String? storedPath = await UserPreferences.getProfilePicture();
    if (storedPath != null && storedPath.isNotEmpty) {
      setState(() {
        profileImagePath = storedPath; // Update the profile image path from preferences
      });
    }
  }

  Future<void> _changeProfilePicture() async {
    final ImagePicker _picker = ImagePicker();

    // Show a dialog to choose between gallery and camera
    final option = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Profile Picture'),
          content: const Text('Choose a source:'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, ImageSource.camera), // Select camera
              child: const Text('Camera'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, ImageSource.gallery), // Select gallery
              child: const Text('Gallery'),
            ),
          ],
        );
      },
    );

    if (option != null) {
      // Pick an image from the chosen source
      final XFile? image = await _picker.pickImage(source: option);
      if (image != null) {
        setState(() {
          profileImagePath = image.path; // Update the profile image path
        });
        await UserPreferences.setProfilePicture(image.path); // Save the new path
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the current theme brightness
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: double.infinity,
      height: 200,
      child: Stack(
        children: [
          CustomPaint(
            painter: HeaderPainter(isDarkMode), // Pass isDarkMode to painter
            size: const Size(double.infinity, 200),
          ),
          Positioned(
            top: 20,
            left: 20,
            child: IconButton(
              onPressed: () {}, // Handle menu button
              icon: const Icon(
                Icons.menu,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            top: 35,
            right: 40,
            child: GestureDetector(
              onTap: _changeProfilePicture, // Trigger the change on tap
              child: CircleAvatar(
                minRadius: 25,
                maxRadius: 25,
                foregroundImage: profileImagePath == 'assets/profile.jpg'
                    ? AssetImage(profileImagePath) as ImageProvider<Object> // Cast AssetImage
                    : FileImage(File(profileImagePath)), // Load image from file
                backgroundColor: Colors.grey[300], // Fallback color
              ),
            ),
          ),
          Positioned(
            left: 33,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black, // Dynamic text color
                    fontWeight: FontWeight.w300,
                    fontSize: 20,
                  ),
                ),
                Text(
                  'Gym goer',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black, // Dynamic text color
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HeaderPainter extends CustomPainter {
  final bool isDarkMode;

  HeaderPainter(this.isDarkMode);

  @override
  void paint(Canvas canvas, Size size) {
    Paint backColor = Paint()..color = isDarkMode ? Colors.black : const Color(0xff18b0e8); // Dynamic background color
    Paint circles = Paint()..color = Colors.white.withAlpha(40);

    canvas.drawRect(
      Rect.fromPoints(
        const Offset(0, 0),
        Offset(size.width, size.height),
      ),
      backColor,
    );

    canvas.drawCircle(Offset(size.width * .65, 10), 30, circles);
    canvas.drawCircle(Offset(size.width * .60, 130), 10, circles);
    canvas.drawCircle(Offset(size.width - 10, size.height - 10), 20, circles);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true; // Ensure it repaints on theme change
}








