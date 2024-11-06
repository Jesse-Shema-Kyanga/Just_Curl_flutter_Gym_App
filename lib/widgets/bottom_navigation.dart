import 'package:flutter/material.dart';

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[850]! // Dark mode background color
        : const Color(0xfff8f8f8); // Light mode background color

    final Color iconColor = Theme.of(context).iconTheme.color ?? Colors.black; // Get the icon color from the theme

    return Container(
      width: double.infinity,
      height: 60,
      color: backgroundColor,
      child: IconTheme(
        data: IconThemeData(color: iconColor),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Icon(
              Icons.add_chart,
              color: Colors.transparent, // Make it transparent or use SizedBox if not needed
            ),
            const Icon(
              Icons.search,
              color: Colors.transparent, // Make it transparent or use SizedBox if not needed
            ),
            Transform.translate(
              offset: const Offset(0, -15),
              child: GestureDetector(
                onTap: () {
                  // Navigate to home page
                  Navigator.of(context).pushReplacementNamed('/home');
                },
                child: Container(
                  padding: const EdgeInsets.all(13),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      colors: [
                        Color(0xff92e2ff),
                        Color(0xff1ebdf8),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        offset: Offset(3, 3),
                        blurRadius: 3,
                      )
                    ],
                  ),
                  child: const Icon(
                    Icons.home,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                // Navigate to details page
                Navigator.pushNamed(context, '/details');
              },
              child: Icon(
                Icons.date_range,
                color: iconColor, // Set a visible color
              ),
            ),
            GestureDetector(
              onTap: () {
                // Navigate to the settings page
                Navigator.of(context).pushNamed('/settings');
              },
              child: const Icon(Icons.settings),
            ),
          ],
        ),
      ),
    );
  }
}

