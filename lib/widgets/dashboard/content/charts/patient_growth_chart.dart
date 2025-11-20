import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; 
import 'dart:math' as math;
import '../../../../controllers/asociados_controller.dart';

class PatientGrowthChart extends StatelessWidget {
  final bool isCompact;

  const PatientGrowthChart({super.key, this.isCompact = false});

  @override
  Widget build(BuildContext context) {
    final AsociadosController controller = Get.find<AsociadosController>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double height = constraints.maxHeight;
        final double heightThreshold = width > 400 ? 140 : 180;
        final bool compactMode = isCompact || height < heightThreshold || width < 250;
        final bool showMetrics = !compactMode && height > 160;
        final bool largeWidth = width > 400;
        final bool mediumWidth = width > 280;
        
        final double barWidth = compactMode ? 2 : (mediumWidth ? 4 : 3);
        final double dotRadius = compactMode ? 2 : 4; // Ajustado ligeramente
        final double fontSizeMetric = compactMode ? 12 : (largeWidth ? 18 : 16);
        final double bottomPadding = compactMode ? 4 : 12;

        return Obx(() {
          final growthData = controller.patientGrowthLast6Months;

          if (growthData.isEmpty) {
            return const Center(child: Text("Sin datos de crecimiento"));
          }

          final List<FlSpot> spots = [];
          for (int i = 0; i < growthData.length; i++) {
            spots.add(FlSpot(i.toDouble(), growthData[i].toDouble()));
          }

          final List<FlSpot> trendSpots = [];
          if (growthData.length >= 2) {
            final double x0 = 0;
            final double y0 = growthData.first.toDouble();
            final double x1 = (growthData.length - 1).toDouble();
            final double y1 = growthData.last.toDouble();
            trendSpots.add(FlSpot(x0, y0));
            trendSpots.add(FlSpot(x1, y1));
          }

          double minY = growthData.reduce(math.min).toDouble();
          double maxY = growthData.reduce(math.max).toDouble();
          
          if (minY > 10) {
            minY -= 10;
          } else {
            minY = 0;
          }

          maxY += (maxY * 0.15);
          double interval = (maxY - minY) / 3;
          if (interval <= 0) interval = 1.0;

          String growthPercentage = "0%";
          Color growthColor = Colors.grey;
          if (growthData.length >= 2) {
            final current = growthData.last;
            final previous = growthData[growthData.length - 2];
            if (previous > 0) {
              final growth = ((current - previous) / previous) * 100;
              growthPercentage = "${growth >= 0 ? '+' : ''}${growth.toStringAsFixed(1)}%";
              growthColor = growth >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444);
            }
          }

          return Column(
            children: [
              // Métricas superiores
              if (showMetrics)
                Padding(
                  padding: EdgeInsets.only(bottom: bottomPadding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetric("Total", growthData.last.toString(), const Color(0xFF4299E1), fontSizeMetric),
                      _buildMetric("Mensual", growthPercentage, growthColor, fontSizeMetric),
                    ],
                  ),
                ),

              Expanded(
                child: LineChart(
                  LineChartData(
                    lineBarsData: [
                      // Línea principal de datos
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: const Color(0xFF4299E1),
                        barWidth: barWidth,
                        belowBarData: BarAreaData(
                          show: !compactMode,
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color.fromARGB(80, 66, 153, 225),
                              Color.fromARGB(0, 66, 153, 225),
                            ],
                          ),
                        ),
                        dotData: FlDotData(
                          show: !compactMode || width > 350, 
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: dotRadius,
                              color: const Color(0xFF4299E1),
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            );
                          },
                        ),
                      ),
                      // Línea de tendencia (punteada)
                      LineChartBarData(
                        spots: trendSpots,
                        isCurved: false,
                        color: const Color(0xFF10B981).withValues(alpha: 0.5),
                        barWidth: 2,
                        dashArray: [5, 5],
                        dotData: const FlDotData(show: false),
                      ),
                    ],

                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: !compactMode,
                          reservedSize: 30,
                          interval: interval,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            final int index = value.toInt();
                            if (index >= 0 && index < 6) {
                              final date = DateTime.now().subtract(
                                Duration(days: 30 * (5 - index)),
                              );
                              final monthName = DateFormat('MMM', 'es').format(date);
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  monthName,
                                  style: TextStyle(
                                    fontSize: compactMode ? 9 : 10,
                                    color: Colors.grey,
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
                      show: !compactMode, 
                      drawHorizontalLine: true,
                      drawVerticalLine: false,
                      horizontalInterval: interval,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Colors.grey.withValues(alpha: 0.1),
                        strokeWidth: 1,
                      ),
                    ),

                    minY: minY,
                    maxY: maxY,

                    lineTouchData: LineTouchData(
                      enabled: width > 200, 
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (spot) => Colors.black.withValues(alpha: 0.8),
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            return LineTooltipItem(
                              '${spot.y.toInt()}',
                              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            );
                          }).toList();
                        },
                      ),
                      handleBuiltInTouches: true,
                    ),
                  ),
                ),
              ),
            ],
          );
        });
      },
    );
  }

  Widget _buildMetric(String label, String value, Color color, double fontSize) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}