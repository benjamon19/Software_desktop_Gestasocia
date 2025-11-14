import 'package:flutter/material.dart';
import '../../../../../../../utils/app_theme.dart';

class CalendarGridWeek extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateTap;
  final Function(DateTime) onTimeSlotTap;

  const CalendarGridWeek({
    super.key,
    required this.selectedDate,
    required this.onDateTap,
    required this.onTimeSlotTap,
  });

  @override
  Widget build(BuildContext context) {
    final DateTime weekStart = _getStartOfWeek(selectedDate);
    final List<DateTime> days = List.generate(6, (i) => weekStart.add(Duration(days: i)));

    return Column(
      children: [
        _buildHeader(context, days, onDateTap, selectedDate),

        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              const startHour = 8;
              const endHour = 19;
              const hoursToShow = endHour - startHour;
              const double border = 0.6;
              final double scale = (constraints.maxWidth / 900).clamp(0.75, 1.0);
              final double availableHeight = constraints.maxHeight - (hoursToShow * border);
              final double cellHeight = availableHeight / hoursToShow;
              final double fontSmall = 10 * scale;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 60 * scale,
                    child: Column(
                      children: List.generate(hoursToShow, (index) {
                        final hour = startHour + index;
                        final String time = hour <= 12 ? "$hour AM" : "${hour - 12} PM";
                        return Container(
                          height: cellHeight,
                          padding: EdgeInsets.only(right: 6 * scale, top: 4 * scale),
                          alignment: Alignment.topRight,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey.withValues(alpha: 0.35),
                                width: border,
                              ),
                              right: BorderSide(
                                color: Colors.grey.withValues(alpha: 0.25),
                                width: border,
                              ),
                            ),
                          ),
                          child: Text(
                            time,
                            style: TextStyle(
                              fontSize: fontSmall,
                              color: AppTheme.getTextSecondary(context),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: List.generate(6, (dayIndex) {
                        final date = days[dayIndex];
                        final bool isSelected = _isSameDay(date, selectedDate);
                        return Expanded(
                          child: Container(
                            color: isSelected
                                ? AppTheme.primaryColor.withValues(alpha: 0.06)
                                : AppTheme.getBackgroundColor(context),
                            child: Column(
                              children: List.generate(hoursToShow, (hourIndex) {
                                return GestureDetector(
                                  onTap: () {
                                    final slot = DateTime(
                                      date.year,
                                      date.month,
                                      date.day,
                                      startHour + hourIndex,
                                    );
                                    onTimeSlotTap(slot);
                                  },
                                  child: Container(
                                    height: cellHeight,
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.grey.withValues(alpha: 0.3),
                                          width: border,
                                        ),
                                        right: BorderSide(
                                          color: Colors.grey.withValues(alpha: 0.2),
                                          width: border,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
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
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, List<DateTime> days, Function(DateTime) onDateTap, DateTime selectedDate) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double scale = (constraints.maxWidth / 900).clamp(0.75, 1.0);
        final double fontMedium = 11 * scale;

        return SizedBox(
          height: 50,
          child: Row(
            children: [
              SizedBox(width: 60 * scale),
              ...days.map((date) {
                final bool isToday = _isSameDay(date, DateTime.now());
                final bool isSelected = _isSameDay(date, selectedDate);
                final String dayLabel = ['L', 'M', 'X', 'J', 'V', 'S'][date.weekday - 1];

                return Expanded(
                  child: GestureDetector(
                    onTap: () => onDateTap(date),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            dayLabel,
                            style: TextStyle(
                              fontSize: fontMedium,
                              fontWeight: FontWeight.w600,
                              color: isToday
                                  ? AppTheme.primaryColor
                                  : AppTheme.getTextSecondary(context),
                            ),
                          ),
                          SizedBox(height: 4),
                          Container(
                            width: 26 * scale,
                            height: 26 * scale,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? AppTheme.primaryColor.withValues(alpha: 0.9)
                                  : isToday
                                      ? AppTheme.primaryColor.withValues(alpha: 0.25)
                                      : Colors.transparent,
                            ),
                            child: Center(
                              child: Text(
                                "${date.day}",
                                style: TextStyle(
                                  fontSize: fontMedium,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : AppTheme.getTextPrimary(context),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  DateTime _getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}