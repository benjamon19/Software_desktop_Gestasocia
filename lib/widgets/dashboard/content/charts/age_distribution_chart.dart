import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../../../models/asociado.dart';
import '../../../../../../../models/carga_familiar.dart';
import '../../../../../../../utils/app_theme.dart';

class AgeDistributionChart extends StatefulWidget {
  final bool isCompact; // Permite modo compacto desde ChartsGridSection

  const AgeDistributionChart({super.key, this.isCompact = false});

  @override
  State<AgeDistributionChart> createState() => _AgeDistributionChartState();
}

class _AgeDistributionChartState extends State<AgeDistributionChart> {
  static Map<String, Map<String, int>>? _cachedDistribution;
  late Future<Map<String, Map<String, int>>> _futureDistribution;

  @override
  void initState() {
    super.initState();
    if (_cachedDistribution != null) {
      _futureDistribution = Future.value(_cachedDistribution);
    } else {
      _futureDistribution = _getAgeDistribution().then((data) {
        _cachedDistribution = data;
        return data;
      });
    }
  }

  Future<Map<String, Map<String, int>>> _getAgeDistribution() async {
    final firestore = FirebaseFirestore.instance;
    final asociadosSnap = await firestore.collection('asociados').get();
    final cargasSnap = await firestore.collection('cargas_familiares').get();

    final List<Asociado> asociados =
        asociadosSnap.docs.map((doc) => Asociado.fromMap(doc.data(), doc.id)).toList();

    final List<CargaFamiliar> cargas =
        cargasSnap.docs.map((doc) => CargaFamiliar.fromMap(doc.data(), doc.id)).toList();

    final Map<String, Map<String, int>> distribution = {
      '0-17': {'asociado': 0, 'carga': 0},
      '18-35': {'asociado': 0, 'carga': 0},
      '36-55': {'asociado': 0, 'carga': 0},
      '56+': {'asociado': 0, 'carga': 0},
    };

    for (var a in asociados) {
      final edad = a.edad;
      if (edad < 18) {
        distribution['0-17']!['asociado'] = distribution['0-17']!['asociado']! + 1;
      } else if (edad <= 35) {
        distribution['18-35']!['asociado'] = distribution['18-35']!['asociado']! + 1;
      } else if (edad <= 55) {
        distribution['36-55']!['asociado'] = distribution['36-55']!['asociado']! + 1;
      } else {
        distribution['56+']!['asociado'] = distribution['56+']!['asociado']! + 1;
      }
    }

    for (var c in cargas) {
      final edad = c.edad;
      if (edad < 18) {
        distribution['0-17']!['carga'] = distribution['0-17']!['carga']! + 1;
      } else if (edad <= 35) {
        distribution['18-35']!['carga'] = distribution['18-35']!['carga']! + 1;
      } else if (edad <= 55) {
        distribution['36-55']!['carga'] = distribution['36-55']!['carga']! + 1;
      } else {
        distribution['56+']!['carga'] = distribution['56+']!['carga']! + 1;
      }
    }

    return distribution;
  }

  void _retry() {
    setState(() {
      _cachedDistribution = null;
      _futureDistribution = _getAgeDistribution().then((data) {
        _cachedDistribution = data;
        return data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bool isSmallScreen = screenWidth < 600;
    final bool isVeryShortScreen = screenHeight < 600;

    // Altura adaptable: más pequeña en modo compacto o pantallas cortas
    double chartHeight;
    if (widget.isCompact) {
      chartHeight = isSmallScreen ? 160 : 200;
    } else if (isVeryShortScreen) {
      chartHeight = 200;
    } else {
      chartHeight = isSmallScreen ? 220 : 320;
    }

    return FutureBuilder<Map<String, Map<String, int>>>(
      future: _futureDistribution,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _ChartLoadingIndicator();
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Error cargando datos',
                    style: TextStyle(color: AppTheme.getTextPrimary(context))),
                const SizedBox(height: 8),
                ElevatedButton(onPressed: _retry, child: const Text('Reintentar')),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
              child: Text('No hay datos disponibles',
                  style: TextStyle(color: AppTheme.getTextSecondary(context))));
        }

        final data = snapshot.data!;
        final int total = data.values.fold(0, (acc, d) => acc + d['asociado']! + d['carga']!);
        final int totalAsociados = data.values.fold(0, (acc, d) => acc + d['asociado']!);
        final int totalCargas = data.values.fold(0, (acc, d) => acc + d['carga']!);

        final List<PointData> points = [];
        for (var rango in ['0-17', '18-35', '36-55', '56+']) {
          final valores = data[rango]!;
          final asociadoPct = _percent(valores['asociado']!, total);
          final cargaPct = _percent(valores['carga']!, total);
          final int cantidadA = valores['asociado']!;
          final int cantidadC = valores['carga']!;

          points.add(PointData(
            label: "$rango (A)",
            value: asociadoPct,
            color: const Color(0xFF3B82F6),
            tooltipMessage: "Asociados $rango\nCantidad: $cantidadA\nPorcentaje: $asociadoPct%",
          ));
          points.add(PointData(
            label: "$rango (C)",
            value: cargaPct,
            color: const Color(0xFF10B981),
            tooltipMessage: "Cargas $rango\nCantidad: $cantidadC\nPorcentaje: $cargaPct%",
          ));
        }

        return SizedBox(
          height: chartHeight,
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: ChartBackgroundPainter(
                    data: points,
                    isSmallScreen: isSmallScreen,
                  ),
                ),
              ),
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: _buildInteractivePoints(points, constraints, isSmallScreen),
                    );
                  },
                ),
              ),
              Positioned(
                top: 8,
                right: 12,
                child: _buildLegend(context, totalAsociados, totalCargas, total),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildInteractivePoints(List<PointData> points, BoxConstraints constraints, bool isSmallScreen) {
    final double marginLeft = 25;
    final double marginBottom = 30;
    final double marginTop = 15;
    final double marginRight = 10;
    final double chartWidth = constraints.maxWidth - marginLeft - marginRight;
    final double chartHeight = constraints.maxHeight - marginTop - marginBottom;
    const double maxValue = 100.0;
    final double pointRadius = isSmallScreen ? 6 : 8;

    return List.generate(points.length, (index) {
      final point = points[index];
      final double left = marginLeft + (chartWidth / (points.length - 1)) * index;
      final double top = constraints.maxHeight - marginBottom - (point.value / maxValue) * chartHeight;

      return Positioned(
        left: left - pointRadius,
        top: top - pointRadius,
        child: Tooltip(
          message: point.tooltipMessage,
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.all(8),
          verticalOffset: 10,
          preferBelow: false,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(6),
          ),
          textStyle: const TextStyle(color: Colors.white, fontSize: 12),
          child: Container(
            width: pointRadius * 2,
            height: pointRadius * 2,
            decoration: BoxDecoration(
              color: point.color,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: point.color.withValues(alpha: 0.4),
                  blurRadius: 4,
                  spreadRadius: 1,
                )
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildLegend(BuildContext context, int totalA, int totalC, int total) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _LegendItem(
            color: const Color(0xFF3B82F6),
            label: 'Asociados: $totalA',
          ),
          const SizedBox(height: 6),
          _LegendItem(
            color: const Color(0xFF10B981),
            label: 'Cargas: $totalC',
          ),
          const SizedBox(height: 6),
          Text(
            'Total: $total',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.getTextSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  double _percent(int value, int total) {
    if (total == 0) return 0;
    return double.parse(((value / total) * 100).toStringAsFixed(1));
  }
}

class ChartBackgroundPainter extends CustomPainter {
  final List<PointData> data;
  final bool isSmallScreen;

  ChartBackgroundPainter({required this.data, required this.isSmallScreen});

  @override
  void paint(Canvas canvas, Size size) {
    final double marginLeft = 25;
    final double marginBottom = 30;
    final double marginTop = 15;
    final double marginRight = 10;
    
    final double chartWidth = size.width - marginLeft - marginRight;
    final double chartHeight = size.height - marginTop - marginBottom;
    const double maxValue = 100.0;

    _drawGrid(canvas, size, marginLeft, marginBottom, chartWidth, chartHeight);
    _drawAxes(canvas, size, marginLeft, marginBottom, chartWidth, chartHeight);
    _drawLabels(canvas, size, marginLeft, marginBottom, chartWidth, chartHeight, maxValue);
  }

  void _drawGrid(Canvas canvas, Size size, double marginLeft, double marginBottom,
      double chartWidth, double chartHeight) {
    final paint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.18)
      ..strokeWidth = 1;
    for (int i = 1; i <= 3; i++) {
      final double y = size.height - marginBottom - (chartHeight / 4) * i;
      canvas.drawLine(
          Offset(marginLeft, y), Offset(marginLeft + chartWidth, y), paint);
    }
  }

  void _drawAxes(Canvas canvas, Size size, double marginLeft, double marginBottom,
      double chartWidth, double chartHeight) {
    final paint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.28)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(marginLeft, size.height - marginBottom),
        Offset(marginLeft, size.height - marginBottom - chartHeight), paint);
    canvas.drawLine(Offset(marginLeft, size.height - marginBottom),
        Offset(marginLeft + chartWidth, size.height - marginBottom), paint);
  }

  void _drawLabels(Canvas canvas, Size size, double marginLeft, double marginBottom,
      double chartWidth, double chartHeight, double maxValue) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    
    for (int i = 0; i <= 4; i += 2) {
      final double value = (maxValue / 4) * i;
      final double y = size.height - marginBottom - (chartHeight / 4) * i;
      textPainter.text = TextSpan(
          text: '${value.toInt()}%',
          style: const TextStyle(fontSize: 10, color: Colors.grey));
      textPainter.layout();
      textPainter.paint(canvas, Offset(marginLeft - 22, y - 6));
    }

    for (int i = 0; i < data.length; i++) {
      final double x = marginLeft + (chartWidth / (data.length - 1)) * i;
      textPainter.text = TextSpan(
          text: data[i].label,
          style: TextStyle(
              fontSize: 9,
              color: data[i].color,
              fontWeight: FontWeight.w600));
      textPainter.layout();
      textPainter.paint(
          canvas, Offset(x - textPainter.width / 2, size.height - marginBottom + 8));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PointData {
  final String label;
  final double value;
  final Color color;
  final String tooltipMessage;

  const PointData({
    required this.label,
    required this.value,
    required this.color,
    required this.tooltipMessage,
  });
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(
                fontSize: 12,
                color: AppTheme.getTextPrimary(context),
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _ChartLoadingIndicator extends StatelessWidget {
  const _ChartLoadingIndicator();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 12),
        Text('Cargando...',
            style: TextStyle(
                color: AppTheme.getTextSecondary(context), fontSize: 14)),
      ]),
    );
  }
}