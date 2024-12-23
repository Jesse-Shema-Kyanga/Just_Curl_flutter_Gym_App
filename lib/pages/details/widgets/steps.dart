import 'package:fitness_tracker/helpers.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class Steps extends StatelessWidget {
  const Steps({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String steps = formatNumber(randBetween(3000, 6000));
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Text(
            steps,
            style: const TextStyle(
              fontSize: 33,
              fontWeight: FontWeight.w900,
            ),
          ),
           Text(
            'totalSteps'.tr(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              height: 2,
            ),
          ),
        ],
      ),
    );
  }
}
