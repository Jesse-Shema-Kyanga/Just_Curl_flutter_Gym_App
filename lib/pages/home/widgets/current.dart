import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_tracker/models/fitness_program.dart';
import 'package:fitness_tracker/pages/exercise/exercise_logging_page.dart';
import 'package:fitness_tracker/pages/running/running_page.dart';

class CurrentPrograms extends StatefulWidget {
  final String? workoutGoal;
  const CurrentPrograms({Key? key, this.workoutGoal}) : super(key: key);

  @override
  State<CurrentPrograms> createState() => _CurrentProgramsState();
}

class _CurrentProgramsState extends State<CurrentPrograms> {
  ProgramType active = fitnessPrograms[0].type;

  @override
  void initState() {
    super.initState();
    if (widget.workoutGoal != null) {
      setState(() {
        active = _getProgramTypeFromGoal(widget.workoutGoal!);
      });
    }
  }

  ProgramType _getProgramTypeFromGoal(String goal) {
    switch (goal) {
      case 'gainMuscle':
        return ProgramType.lift;
      case 'loseFat':
        return ProgramType.cardio;
      case 'improveCardio':
        return ProgramType.cardio;
      default:
        return fitnessPrograms[0].type;
    }
  }


  void _changeProgram(ProgramType newType) {
    setState(() {
      active = newType;
    });

    // Navigate based on program type
    if (newType == ProgramType.cardio) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RunningPage()),
      );
    } else if (newType == ProgramType.lift) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ExerciseLoggingPage()),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'currentPrograms'.tr(),
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ) ??
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 15,
              ),
            ],
          ),
        ),
        SizedBox(
          height: 120,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            scrollDirection: Axis.horizontal,
            itemCount: fitnessPrograms.length,
            itemBuilder: (context, index) {
              return ProgramItem(
                program: fitnessPrograms[index],
                active: fitnessPrograms[index].type == active,
                onTap: _changeProgram,
              );
            },
            separatorBuilder: (context, index) => const SizedBox(width: 20),
          ),
        ),
      ],
    );
  }
}

class ProgramItem extends StatelessWidget {
  final FitnessProgram program;
  final bool active;
  final Function(ProgramType) onTap;

  const ProgramItem({
    Key? key,
    required this.program,
    required this.active,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap(program.type);
      },
      child: Container(
        height: 100,
        width: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: active ? Theme.of(context).primaryColor : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
          image: DecorationImage(
            colorFilter: ColorFilter.mode(
              active
                  ? const Color(0xff1ebdf8).withOpacity(.8)
                  : Colors.white.withOpacity(.8),
              BlendMode.lighten,
            ),
            image: program.image,
            fit: BoxFit.cover,
          ),
        ),
        alignment: Alignment.bottomLeft,
        padding: const EdgeInsets.all(15),
        child: DefaultTextStyle.merge(
          style: TextStyle(
            color: active ? Colors.white : Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(program.name.tr()),
              Row(
                children: [
                  Text('cals'.tr(namedArgs: {'cals': program.cals})),
                  const SizedBox(width: 15),
                  Icon(
                    Icons.timer,
                    size: 12,
                    color: active ? Colors.white : Colors.black,
                  ),
                  const SizedBox(width: 5),
                  Text('time'.tr(namedArgs: {'time': program.time})),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
