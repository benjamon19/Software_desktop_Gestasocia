import 'package:flutter/material.dart';
import '../../../../../../utils/app_theme.dart';

class AppointmentCard extends StatelessWidget {
  final String title;
  final String patient;
  final String time;
  final Color color;
  final VoidCallback onTap;

  const AppointmentCard({
    super.key,
    required this.title,
    required this.patient,
    required this.time,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 40),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
          border: Border(left: BorderSide(color: color, width: 3)),
        ),
        padding: const EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600, color: color),
            ),
            const SizedBox(height: 2),
            Text(patient,
                style: TextStyle(
                    fontSize: 10, color: AppTheme.getTextPrimary(context))),
            const SizedBox(height: 3),
            Row(
              children: [
                Icon(Icons.access_time,
                    size: 10, color: AppTheme.getTextSecondary(context)),
                const SizedBox(width: 4),
                Text(time,
                    style: TextStyle(
                        fontSize: 9, color: AppTheme.getTextSecondary(context))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
