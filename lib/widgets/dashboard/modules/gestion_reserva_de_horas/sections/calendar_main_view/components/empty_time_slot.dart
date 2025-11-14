import 'package:flutter/material.dart';
import '../../../../../../../utils/app_theme.dart';

class EmptyTimeSlot extends StatelessWidget {
  final VoidCallback onTap;
  final double height;
  final String? label;

  const EmptyTimeSlot({
    super.key,
    required this.onTap,
    this.height = 60,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        color: Colors.transparent,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 12),
        child: label != null
            ? Text(
                label!,
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.getTextSecondary(context).withValues(alpha: 0.6),
                ),
              )
            : null,
      ),
    );
  }
}