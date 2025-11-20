import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import '../../../../controllers/historial_clinico_controller.dart';

class TreatmentTypesChart extends StatelessWidget {
  final bool isCompact; // Permite forzar modo compacto desde ChartsGridSection

  const TreatmentTypesChart({super.key, this.isCompact = false});

  @override
  Widget build(BuildContext context) {
    final HistorialClinicoController controller = Get.find<HistorialClinicoController>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double height = constraints.maxHeight;

        // Inteligencia: modo compacto si se fuerza o si hay poco espacio
        final bool compactMode = isCompact || width < 300 || height < 160;

        // Ajustes finos según espacio
        final double barWidth = compactMode ? 16 : 28;
        final double fontSize = compactMode ? 7.5 : 10;
        final double maxLabelLength = compactMode ? 3 : 6;
        final bool showGrid = height > 180;
        final bool showTooltip = height > 150;

        return Obx(() {
          final treatmentStats = controller.tratamientosPorTipo;
          
          if (treatmentStats.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.bar_chart,
                    size: compactMode ? 32 : 48,
                    color: Colors.grey.withValues(alpha: 0.3),
                  ),
                  SizedBox(height: compactMode ? 6 : 12),
                  Text(
                    'No hay datos',
                    style: TextStyle(
                      fontSize: compactMode ? 10 : 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          final data = _getChartData(treatmentStats);

          return BarChart(
            BarChartData(
              barGroups: data.asMap().entries.map((entry) {
                int index = entry.key;
                TreatmentData d = entry.value;
                
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: d.value,
                      color: d.color,
                      width: barWidth,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(6),
                        topRight: Radius.circular(6),
                      ),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: 100,
                        color: d.color.withValues(alpha: 0.1),
                      ),
                    )
                  ],
                );
              }).toList(),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: showGrid,
                    reservedSize: compactMode ? 20 : 35,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toInt()}%',
                        style: TextStyle(
                          fontSize: compactMode ? 7 : fontSize,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      int index = value.toInt();
                      if (index >= 0 && index < data.length) {
                        return Padding(
                          padding: EdgeInsets.only(top: compactMode ? 4 : 8),
                          child: SizedBox(
                            width: barWidth * 1.8,
                            child: Text(
                              _truncateLabel(data[index].name, maxLabelLength.toInt()),
                              style: TextStyle(
                                fontSize: fontSize,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: showGrid,
                drawHorizontalLine: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.grey.withValues(alpha: 0.2),
                  strokeWidth: 1,
                ),
              ),
              maxY: 100,
              barTouchData: BarTouchData(
                enabled: showTooltip,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (group) => Colors.black.withValues(alpha: 0.8),
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final item = data[group.x.toInt()];
                    return BarTooltipItem(
                      '${item.name}\n',
                      const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      children: [
                        TextSpan(
                          text: '${rod.toY.toStringAsFixed(1)}%',
                          style: const TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          );
        });
      },
    );
  }

  List<TreatmentData> _getChartData(Map<String, int> counts) {
    final total = counts.values.fold(0, (sum, item) => sum + item);
    if (total == 0) return [];
    
    final sortedEntries = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final List<TreatmentData> data = [];
    final colors = [
      const Color(0xFF3B82F6), const Color(0xFF10B981), 
      const Color(0xFFF59E0B), const Color(0xFFEF4444), 
      const Color(0xFF8B5CF6)
    ];

    for (int i = 0; i < sortedEntries.length && i < 4; i++) {
      final entry = sortedEntries[i];
      data.add(TreatmentData(
        name: entry.key,
        value: (entry.value / total) * 100,
        color: colors[i % colors.length],
      ));
    }

    if (sortedEntries.length > 4) {
      int othersCount = 0;
      for (int i = 4; i < sortedEntries.length; i++) {
        othersCount += sortedEntries[i].value;
      }
      data.add(TreatmentData(
        name: 'Otros',
        value: (othersCount / total) * 100,
        color: colors[4],
      ));
    }

    return data;
  }

  String _truncateLabel(String label, int maxLength) {
    if (label.length > maxLength) {
      return '${label.substring(0, maxLength)}..';
    }
    return label;
  }
}

class TreatmentData {
  final String name;
  final double value;
  final Color color;
  const TreatmentData({required this.name, required this.value, required this.color});
}