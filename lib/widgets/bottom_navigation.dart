// bottom_navigation.dart
import 'package:flutter/material.dart';

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[850]!
        : const Color(0xfff8f8f8);

    final Color iconColor = Theme.of(context).iconTheme.color ?? Colors.black;

    return Container(
      width: double.infinity,
      height: 60,
      color: backgroundColor,
      child: IconTheme(
        data: IconThemeData(color: iconColor),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/details');
              },
              child: Icon(
                Icons.date_range,
                color: iconColor,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/exercise');
              },
              child: Icon(
                Icons.fitness_center,
                color: iconColor,
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -15),
              child: GestureDetector(
                onTap: () {
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
                Navigator.of(context).pushNamed('/running');
              },
              child: Icon(
                Icons.directions_run,
                color: iconColor,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed('/settings');
              },
              child: Icon(
                Icons.settings,
                color: iconColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
