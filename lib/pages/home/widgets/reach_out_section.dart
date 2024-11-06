import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ReachOutSection extends StatelessWidget {
  const ReachOutSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the current theme brightness
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final phoneNumber = '0785609816'; // Replace with the actual phone number

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Having trouble? Reach out to us!',
            style: TextStyle(
              fontSize: 16, // Smaller font size
              color: isDarkMode ? Colors.white : Colors.black, // Dynamic text color
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              final Uri launchUri = Uri(
                scheme: 'tel',
                path: phoneNumber,
              );
              if (await canLaunch(launchUri.toString())) {
                await launch(launchUri.toString());
              } else {
                throw 'Could not launch $launchUri';
              }
            },
            child: Text(
              phoneNumber,
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue, // Color for the hyperlink
                decoration: TextDecoration.underline, // Underline for hyperlink effect
              ),
            ),
          ),
        ],
      ),
    );
  }
}


