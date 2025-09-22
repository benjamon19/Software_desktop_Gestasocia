import 'package:flutter/material.dart';
import 'components/metric_card.dart';

class MetricsSection extends StatelessWidget {
  const MetricsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bool isSmallScreen = screenWidth < 600;
    final bool hasVerticalSpace = screenHeight > 600; // Detecta si hay espacio vertical
    
    return Row(
      children: [
        Expanded(
          child: MetricCard(
            title: 'Total Cargas',
            value: '52',
            icon: Icons.group_outlined,
            iconColor: const Color(0xFF4299E1),
            backgroundColor: const Color(0xFFEBF8FF),
            isSmallScreen: isSmallScreen,
            hasVerticalSpace: hasVerticalSpace,
          ),
        ),
        SizedBox(width: isSmallScreen ? 8 : 12),
        Expanded(
          child: MetricCard(
            title: 'Pendientes',
            value: '8',
            icon: Icons.pending_actions_outlined,
            iconColor: const Color(0xFF48BB78),
            backgroundColor: const Color(0xFFF0FDF4),
            isSmallScreen: isSmallScreen,
            hasVerticalSpace: hasVerticalSpace,
          ),
        ),
        SizedBox(width: isSmallScreen ? 8 : 12),
        Expanded(
          child: MetricCard(
            title: 'Vencimientos',
            value: '3',
            icon: Icons.schedule_outlined,
            iconColor: const Color(0xFF9F7AEA),
            backgroundColor: const Color(0xFFF9F5FF),
            isSmallScreen: isSmallScreen,
            hasVerticalSpace: hasVerticalSpace,
          ),
        ),
        SizedBox(width: isSmallScreen ? 8 : 12),
        Expanded(
          child: MetricCard(
            title: 'Urgencias',
            value: '2',
            icon: Icons.warning_amber_outlined,
            iconColor: const Color(0xFFF56565),
            backgroundColor: const Color(0xFFFFF5F5),
            isSmallScreen: isSmallScreen,
            hasVerticalSpace: hasVerticalSpace,
          ),
        ),
      ],
    );
  }
}