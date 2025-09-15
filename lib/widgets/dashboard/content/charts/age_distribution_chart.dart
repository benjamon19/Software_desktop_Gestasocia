import 'package:flutter/material.dart';

class AgeDistributionChart extends StatelessWidget {
  const AgeDistributionChart({super.key});

  // Datos para clínica dental
  final List<PointData> _ageData = const [
    PointData(label: "0-17", value: 15, color: Color(0xFF60A5FA)),
    PointData(label: "18-35", value: 35, color: Color(0xFF34D399)),
    PointData(label: "36-55", value: 32, color: Color(0xFFFBBF24)),
    PointData(label: "56+", value: 18, color: Color(0xFFF87171)),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 600;
    
    return CustomPaint(
      painter: CompactScatterPainter(
        data: _ageData,
        isSmallScreen: isSmallScreen,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class CompactScatterPainter extends CustomPainter {
  final List<PointData> data;
  final bool isSmallScreen;

  CompactScatterPainter({
    required this.data,
    required this.isSmallScreen,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    // Configuración responsiva
    final double pointRadius = isSmallScreen ? 6 : 8;
    final double marginLeft = 25;
    final double marginBottom = 25;
    final double marginTop = 15;
    final double marginRight = 10;
    
    final double chartWidth = size.width - marginLeft - marginRight;
    final double chartHeight = size.height - marginTop - marginBottom;
    final double maxValue = 40.0;
    
    // Dibujar grid
    _drawGrid(canvas, size, marginLeft, marginBottom, chartWidth, chartHeight);
    
    // Dibujar ejes
    _drawAxes(canvas, size, marginLeft, marginBottom, chartWidth, chartHeight);
    
    // Dibujar puntos scatter
    for (int i = 0; i < data.length; i++) {
      final point = data[i];
      
      // Posición base
      final double baseX = marginLeft + (chartWidth / (data.length - 1)) * i;
      final double baseY = size.height - marginBottom - (point.value / maxValue) * chartHeight;
      
      // Múltiples puntos para efecto scatter
      final List<Offset> positions = [
        Offset(baseX, baseY), // Principal
        Offset(baseX - 8, baseY + 6),
        Offset(baseX + 5, baseY - 4),
        Offset(baseX - 3, baseY - 8),
        Offset(baseX + 8, baseY + 3),
      ];
      
      final List<double> sizes = [pointRadius, pointRadius * 0.6, pointRadius * 0.5, pointRadius * 0.4, pointRadius * 0.7];
      final List<double> alphas = [1.0, 0.8, 0.6, 0.5, 0.7];
      
      for (int j = 0; j < positions.length; j++) {
        paint.color = point.color.withValues(alpha: alphas[j]);
        canvas.drawCircle(positions[j], sizes[j], paint);
      }
    }
    
    // Etiquetas
    _drawLabels(canvas, size, marginLeft, marginBottom, chartWidth, chartHeight, maxValue);
  }

  void _drawGrid(Canvas canvas, Size size, double marginLeft, double marginBottom, 
                double chartWidth, double chartHeight) {
    final paint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.2)
      ..strokeWidth = 1;
    
    // Líneas horizontales
    for (int i = 1; i <= 3; i++) {
      final double y = size.height - marginBottom - (chartHeight / 4) * i;
      canvas.drawLine(
        Offset(marginLeft, y),
        Offset(marginLeft + chartWidth, y),
        paint,
      );
    }
  }

  void _drawAxes(Canvas canvas, Size size, double marginLeft, double marginBottom,
                double chartWidth, double chartHeight) {
    final paint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.3)
      ..strokeWidth = 1;
    
    // Eje Y
    canvas.drawLine(
      Offset(marginLeft, size.height - marginBottom),
      Offset(marginLeft, size.height - marginBottom - chartHeight),
      paint,
    );
    
    // Línea base
    canvas.drawLine(
      Offset(marginLeft, size.height - marginBottom),
      Offset(marginLeft + chartWidth, size.height - marginBottom),
      paint,
    );
  }

  void _drawLabels(Canvas canvas, Size size, double marginLeft, double marginBottom,
                  double chartWidth, double chartHeight, double maxValue) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    
    // Etiquetas Y
    for (int i = 0; i <= 4; i += 2) {
      final double value = (maxValue / 4) * i;
      final double y = size.height - marginBottom - (chartHeight / 4) * i;
      
      textPainter.text = TextSpan(
        text: '${value.toInt()}%',
        style: const TextStyle(
          fontSize: 10,
          color: Colors.grey,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(marginLeft - 22, y - 5));
    }
    
    // Etiquetas X
    for (int i = 0; i < data.length; i++) {
      final double x = marginLeft + (chartWidth / (data.length - 1)) * i;
      
      textPainter.text = TextSpan(
        text: data[i].label,
        style: const TextStyle(
          fontSize: 9,
          color: Colors.grey,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, size.height - marginBottom + 8));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PointData {
  final String label;
  final double value;
  final Color color;

  const PointData({
    required this.label,
    required this.value,
    required this.color,
  });
}