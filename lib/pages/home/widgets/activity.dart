import 'dart:math';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class RecentActivities extends StatelessWidget {
  const RecentActivities({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'recentActivity'.tr(),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ) ??
                const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox( // Fixed size to prevent overflow
            height: 200,
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) => const ActivityItem(),
            ),
          ),
        ],
      ),
    );
  }
}

class ActivityItem extends StatelessWidget {
  const ActivityItem({Key? key}) : super(key: key);

  static const activities = [
    'running',
    'swimming',
    'hiking',
    'walking',
    'cycling',
  ];

  @override
  Widget build(BuildContext context) {
    String activityKey = activities[Random().nextInt(activities.length)];
    String activity = activityKey.tr();

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed('/details');
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        height: 70,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xffcff2ff),
              ),
              height: 35,
              width: 35,
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage('assets/running.jpg'),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Text(
              activity,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const Spacer(),
            const Icon(Icons.timer, size: 12),
            const SizedBox(width: 5),
            Text(
              'thirtyMin'.tr(),
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w300),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.wb_sunny_outlined, size: 12),
            const SizedBox(width: 5),
            Text(
              'fiftyFiveKcal'.tr(),
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w300),
            ),
            const SizedBox(width: 20),
          ],
        ),
      ),
    );
  }
}
