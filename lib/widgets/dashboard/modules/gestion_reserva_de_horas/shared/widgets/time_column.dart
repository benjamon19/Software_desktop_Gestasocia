import 'package:flutter/material.dart';
import '../../../../../../utils/app_theme.dart';

class TimeColumn extends StatelessWidget {
  final int startHour;
  final int endHour;

  const TimeColumn({
    super.key,
    this.startHour = 8,
    this.endHour = 20,
  });

  @override
  Widget build(BuildContext context) {
    final hours = endHour - startHour;
    return SizedBox(
      width: 60,
      child: Column(
        children: List.generate(hours, (i) {
          final hour = startHour + i;
          final time = hour <= 12 ? '$hour AM' : '${hour - 12} PM';
          return SizedBox(
            height: 50,
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 8, top: 4),
                child: Text(
                  time,
                  style: TextStyle(fontSize: 11, color: AppTheme.getTextSecondary(context)),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}