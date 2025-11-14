import 'package:flutter/material.dart';
import '../../../../../../../utils/app_theme.dart';

class CalendarGridDay extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onTimeSlotTap;

  const CalendarGridDay({
    super.key,
    required this.selectedDate,
    required this.onTimeSlotTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.getBackgroundColor(context),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const startHour = 8;
          const endHour = 20; // 8 AM a 8 PM → 12 horas
          const hoursToShow = endHour - startHour;
          const double borderWidth = 0.6;

          final double cellHeight = constraints.maxHeight / hoursToShow;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Columna de horas
              SizedBox(
                width: 60,
                child: Column(
                  children: List.generate(hoursToShow, (index) {
                    final hour = startHour + index;
                    final time = hour <= 12 ? '$hour AM' : '${hour - 12} PM';
                    return Container(
                      height: cellHeight,
                      padding: const EdgeInsets.only(right: 8, top: 4),
                      alignment: Alignment.topRight,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.withValues(alpha: 0.35),
                            width: borderWidth,
                          ),
                          right: BorderSide(
                            color: Colors.grey.withValues(alpha: 0.25),
                            width: borderWidth,
                          ),
                        ),
                      ),
                      child: Text(
                        time,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.getTextSecondary(context),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              // Grid de slots horarios
              Expanded(
                child: Column(
                  children: List.generate(hoursToShow, (index) {
                    final DateTime slot = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                      startHour + index,
                    );

                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onTimeSlotTap(slot),
                      child: Container(
                        height: cellHeight,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey.withValues(alpha: 0.3),
                              width: borderWidth,
                            ),
                            right: BorderSide(
                              color: Colors.grey.withValues(alpha: 0.2),
                              width: borderWidth,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}