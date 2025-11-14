import 'package:flutter/material.dart';
import '../../../../../../../utils/app_theme.dart';

class ViewSelectorButtons extends StatelessWidget {
  final String selectedView;
  final Function(String) onViewChanged;

  const ViewSelectorButtons({
    super.key,
    required this.selectedView,
    required this.onViewChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'Vista',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextSecondary(context),
              letterSpacing: 0.5,
            ),
          ),
        ),
        
        Container(
          decoration: BoxDecoration(
            color: AppTheme.getInputBackground(context),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppTheme.getBorderLight(context),
            ),
          ),
          child: Column(
            children: [
              _buildViewOption(
                context,
                icon: Icons.view_day,
                label: 'Día',
                value: 'day',
              ),
              Divider(
                height: 1,
                color: AppTheme.getBorderLight(context),
              ),
              _buildViewOption(
                context,
                icon: Icons.view_week,
                label: 'Semana',
                value: 'week',
              ),
              Divider(
                height: 1,
                color: AppTheme.getBorderLight(context),
              ),
              _buildViewOption(
                context,
                icon: Icons.calendar_view_month,
                label: 'Mes',
                value: 'month',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildViewOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final isSelected = selectedView == value;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onViewChanged(value),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? AppTheme.primaryColor
                    : AppTheme.getTextSecondary(context),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected
                        ? AppTheme.primaryColor
                        : AppTheme.getTextPrimary(context),
                  ),
                ),
              ),
              if (isSelected)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}