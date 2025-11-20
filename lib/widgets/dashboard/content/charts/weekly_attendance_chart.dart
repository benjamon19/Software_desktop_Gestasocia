import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import '../../../../utils/app_theme.dart';
import '../../../../controllers/reserva_horas_controller.dart';

class WeeklyAttendanceChart extends StatelessWidget {
  final bool isCompact; // Permite forzar modo compacto desde ChartsGridSection

  const WeeklyAttendanceChart({super.key, this.isCompact = false});

  @override
  Widget build(BuildContext context) {
    final ReservaHorasController controller = Get.find<ReservaHorasController>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double height = constraints.maxHeight;

        // Modo compacto: forzado o por espacio limitado
        final bool compactMode = isCompact || width < 300 || height < 180;

        final double fontSize = compactMode ? 9 : 12;
        final double barWidth = compactMode ? 2 : 4;
        final double dotRadius = compactMode ? 2.5 : 5;
        final bool showArea = height > 220 && !compactMode;
        final bool showLegend = height > 160;
        final double titleSpacing = compactMode ? 2 : 4;
        final double topSpacing = compactMode ? 12 : 24;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Asistencia Mensual',
              style: TextStyle(
                fontSize: fontSize + 4,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextPrimary(context),
              ),
            ),
            SizedBox(height: titleSpacing),
            Text(
              'Comparativa Realizadas vs Canceladas',
              style: TextStyle(
                fontSize: fontSize,
                color: AppTheme.getTextSecondary(context),
              ),
            ),
            SizedBox(height: topSpacing),

            Expanded(
              flex: showLegend ? 4 : 5,
              child: Obx(() {
                final data = controller.attendanceStatsLast4Weeks;
                if (data.isEmpty) {
                  return const Center(child: Text('Sin datos'));
                }

                double maxY = 0;
                for (var item in data) {
                  if (item.attended > maxY) maxY = item.attended.toDouble();
                  if (item.missed > maxY) maxY = item.missed.toDouble();
                }
                if (maxY < 5) maxY = 5;
                maxY += (maxY * 0.2);
                double interval = (maxY / 4).floorToDouble();
                if (interval <= 0) interval = 1;

                return LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: !compactMode,
                      drawVerticalLine: false,
                      horizontalInterval: interval,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Colors.grey.withValues(alpha: 0.1),
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: compactMode ? 20 : 30,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= 0 && index < data.length) {
                              String label = data[index].label;
                              if (compactMode) {
                                if (label.contains('Sem ')) {
                                  label = label.replaceAll('Sem ', 'S');
                                } else if (label.length > 6) {
                                  label = '${label.substring(0, 5)}..';
                                }
                              }
                              return SideTitleWidget(
                                meta: meta,
                                space: compactMode ? 2 : 4,
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: fontSize - 2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: !compactMode,
                          interval: interval,
                          reservedSize: compactMode ? 20 : 30,
                          getTitlesWidget: (value, meta) {
                            if (value % 1 != 0) return const SizedBox.shrink();
                            return Text(
                              value.toInt().toString(),
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: fontSize - 2,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    minX: 0,
                    maxX: (data.length - 1).toDouble(),
                    minY: 0,
                    maxY: maxY,
                    lineBarsData: [
                      LineChartBarData(
                        spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.attended.toDouble())).toList(),
                        isCurved: !compactMode,
                        color: const Color(0xFF10B981),
                        barWidth: barWidth,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: !compactMode,
                          getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                            radius: dotRadius,
                            color: const Color(0xFF10B981),
                            strokeWidth: compactMode ? 1 : 2,
                            strokeColor: Colors.white,
                          ),
                        ),
                        belowBarData: BarAreaData(
                          show: showArea,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              const Color(0xFF10B981).withValues(alpha: 0.3),
                              const Color(0xFF10B981).withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                      LineChartBarData(
                        spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.missed.toDouble())).toList(),
                        isCurved: !compactMode,
                        color: const Color(0xFFEF4444),
                        barWidth: barWidth,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: !compactMode,
                          getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                            radius: dotRadius,
                            color: const Color(0xFFEF4444),
                            strokeWidth: compactMode ? 1 : 2,
                            strokeColor: Colors.white,
                          ),
                        ),
                        belowBarData: BarAreaData(show: false),
                      ),
                    ],
                    lineTouchData: LineTouchData(
                      enabled: !compactMode,
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (spot) => Colors.black.withValues(alpha: 0.8),
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            final isAttendance = spot.barIndex == 0;
                            return LineTooltipItem(
                              '${isAttendance ? "Asistieron" : "Faltaron"}: ${spot.y.toInt()}',
                              TextStyle(
                                color: isAttendance ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                fontWeight: FontWeight.bold,
                                fontSize: fontSize,
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ),
                );
              }),
            ),
            if (showLegend)
            Expanded(
              flex: 1,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildLegendItem("Asistieron", const Color(0xFF10B981), fontSize, compactMode),
                    SizedBox(width: compactMode ? 8 : 20),
                    _buildLegendItem("Faltaron", const Color(0xFFEF4444), fontSize, compactMode),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLegendItem(String label, Color color, double fontSize, bool compactMode) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: compactMode ? 2 : 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: compactMode ? 4 : 6),
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize - 1,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}