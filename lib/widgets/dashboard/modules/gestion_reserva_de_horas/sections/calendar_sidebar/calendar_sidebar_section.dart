import 'package:flutter/material.dart';
import '../../../../../../utils/app_theme.dart';
import 'components/mini_calendar_widget.dart';

class CalendarSidebarSection extends StatelessWidget {
  final DateTime selectedDate;
  final String selectedView;
  final Function(DateTime) onDateSelected;
  final Function(String) onViewChanged;

  const CalendarSidebarSection({
    super.key,
    required this.selectedDate,
    required this.selectedView,
    required this.onDateSelected,
    required this.onViewChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.getSurfaceColor(context),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final scale = (width / 280).clamp(0.45, 1.0);

          return Scrollbar(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Navegación',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16 * scale,
                    ),
                  ),
                  SizedBox(height: 12 * scale),
                  MiniCalendarWidget(
                    selectedDate: selectedDate,
                    onDateSelected: onDateSelected,
                  ),
                  SizedBox(height: 20 * scale),
                  Text(
                    'Vista',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16 * scale,
                    ),
                  ),
                  SizedBox(height: 8 * scale),
                  _buildViewOption(context, 'Día', 'day', Icons.calendar_view_day_outlined, scale),
                  SizedBox(height: 4 * scale),
                  _buildViewOption(context, 'Semana', 'week', Icons.calendar_view_week_outlined, scale),
                  SizedBox(height: 4 * scale),
                  _buildViewOption(context, 'Mes', 'month', Icons.calendar_month_outlined, scale),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildViewOption(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    double scale,
  ) {
    final isSelected = selectedView == value;

    return InkWell(
      onTap: () => onViewChanged(value),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 10 * scale,
          horizontal: 12 * scale,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.1) : null,
          borderRadius: BorderRadius.circular(8 * scale),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20 * scale,
              color: isSelected
                  ? AppTheme.primaryColor
                  : AppTheme.getTextSecondary(context),
            ),
            SizedBox(width: 12 * scale),
            Text(
              label,
              style: TextStyle(
                fontSize: 14 * scale,
                color: isSelected
                    ? AppTheme.primaryColor
                    : AppTheme.getTextPrimary(context),
                fontWeight: isSelected ? FontWeight.w600 : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
