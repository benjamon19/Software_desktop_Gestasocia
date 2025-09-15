// lib/widgets/dashboard/modules/gestion_cargas_familiares/sections/metrics_section/metrics_section.dart
import 'package:flutter/material.dart';
import 'components/metric_card.dart';

class MetricsSection extends StatelessWidget {
  const MetricsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: MetricCard(
            title: 'Total Cargas',
            value: '52',
            icon: Icons.group_outlined,
            iconColor: const Color(0xFF4299E1),
            backgroundColor: const Color(0xFFEBF8FF),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: MetricCard(
            title: 'Pendientes',
            value: '8',
            icon: Icons.pending_actions_outlined,
            iconColor: const Color(0xFF48BB78),
            backgroundColor: const Color(0xFFF0FDF4),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: MetricCard(
            title: 'Vencimientos',
            value: '3',
            icon: Icons.schedule_outlined,
            iconColor: const Color(0xFF9F7AEA),
            backgroundColor: const Color(0xFFF9F5FF),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: MetricCard(
            title: 'Urgencias',
            value: '2',
            icon: Icons.warning_amber_outlined,
            iconColor: const Color(0xFFF56565),
            backgroundColor: const Color(0xFFFFF5F5),
          ),
        ),
      ],
    );
  }
}