import 'package:flutter/material.dart';
import '../../../../../../../utils/app_theme.dart';

class CalendarGridMonth extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateTap;

  const CalendarGridMonth({
    super.key,
    required this.selectedDate,
    required this.onDateTap,
  });

  @override
  Widget build(BuildContext context) {
    final DateTime firstDayOfMonth =
        DateTime(selectedDate.year, selectedDate.month, 1);

    final int weekdayOffset = firstDayOfMonth.weekday % 7;

    final DateTime firstVisibleDate =
        firstDayOfMonth.subtract(Duration(days: weekdayOffset));

    final int daysInMonth =
        DateTime(selectedDate.year, selectedDate.month + 1, 0).day;

    final int totalCells = weekdayOffset + daysInMonth;
    final int totalRows = (totalCells / 7).ceil();

    final List<DateTime> visibleDays = List.generate(
      totalRows * 7,
      (i) => firstVisibleDate.add(Duration(days: i)),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final double cellWidth = constraints.maxWidth / 7;

        final double rowHeight = constraints.maxHeight / (totalRows + 0.5);

        return Column(
          children: [
            // Encabezado de días
            SizedBox(
              height: rowHeight * 0.5,
              child: _buildWeekHeader(context),
            ),

            SizedBox(
              height: rowHeight * totalRows,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: cellWidth / rowHeight,
                ),
                itemCount: visibleDays.length,
                itemBuilder: (context, index) {
                  final day = visibleDays[index];
                  final bool isToday = _isSameDay(day, DateTime.now());
                  final bool isSelected = _isSameDay(day, selectedDate);
                  final bool isCurrentMonth =
                      day.month == selectedDate.month;

                  return GestureDetector(
                    onTap: () => onDateTap(day),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.2),
                        ),
                        color: isSelected
                            ? AppTheme.primaryColor.withValues(alpha: 0.08)
                            : Colors.transparent,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: isToday
                                  ? AppTheme.primaryColor.withValues(alpha: 0.9)
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              "${day.day}",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight:
                                    isToday ? FontWeight.bold : FontWeight.normal,
                                color: isCurrentMonth
                                    ? AppTheme.getTextPrimary(context)
                                    : AppTheme.getTextSecondary(context)
                                        .withValues(alpha: 0.35),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWeekHeader(BuildContext context) {
    const days = ["L", "M", "M", "J", "V", "S", "D"];
    return Row(
      children: days
          .map(
            (d) => Expanded(
              child: Center(
                child: Text(
                  d,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getTextSecondary(context),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
