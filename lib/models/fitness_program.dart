import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

enum ProgramType {
  cardio,
  lift,
}

class FitnessProgram {
  final AssetImage image;
  final String name;
  final String cals;
  final String time;
  final ProgramType type;

  FitnessProgram({
    required this.image,
    required this.name,
    required this.cals,
    required this.time,
    required this.type,
  });
}

final List<FitnessProgram> fitnessPrograms = [
  FitnessProgram(
    image: const AssetImage('assets/running.jpg'),
    name: 'cardio'.tr(), // Localized key for "Cardio"
    cals: 'cals'.tr(namedArgs: {'cals': '220kkal'}), // Localized dynamic key for calories
    time: 'time'.tr(namedArgs: {'time': '20min'}), // Localized dynamic key for time
    type: ProgramType.cardio,
  ),
  FitnessProgram(
    image: const AssetImage('assets/weights.jpg'),
    name: 'barbelArmLift'.tr(), // Localized key for "Barbel Arm Lift"
    cals: 'cals'.tr(namedArgs: {'cals': '220kkal'}), // Localized dynamic key for calories
    time: 'time'.tr(namedArgs: {'time': '20min'}), // Localized dynamic key for time
    type: ProgramType.lift,
  ),
];
