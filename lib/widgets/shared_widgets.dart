import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../utils/app_theme.dart';

class LeftPanel extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<FeatureItem> features;

  const LeftPanel({
    super.key,
    required this.title,
    required this.subtitle,
    required this.features,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 5,
      child: Container(
        decoration: const BoxDecoration(color: AppTheme.secondaryColor),
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: BackgroundPainter())),
            Padding(
              padding: const EdgeInsets.all(60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/gestasocia_icon.png',
                        width: 75,
                        height: 75,
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'GestAsocia',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Sistema de Gestión de Asociados',
                    style: TextStyle(fontSize: 18, color: Colors.white70),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Column(
                      children: features
                          .map((feature) => Padding(
                                padding: EdgeInsets.only(
                                  bottom: feature != features.last ? 16 : 0,
                                ),
                                child: Row(
                                  children: [
                                    Icon(feature.icon, color: AppTheme.primaryColor, size: 20),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        feature.text,
                                        style: const TextStyle(color: Colors.white70),
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeatureItem {
  final IconData icon;
  final String text;

  const FeatureItem({required this.icon, required this.text});
}

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final bool obscureText;
  final void Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.onChanged,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      onChanged: onChanged,
      inputFormatters: inputFormatters,
      style: TextStyle(
        color: AppTheme.getTextPrimary(context),
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(
          icon, 
          size: 20,
          color: AppTheme.getTextSecondary(context),
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppTheme.getInputBackground(context),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          borderSide: BorderSide(color: AppTheme.getBorderLight(context)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
        labelStyle: TextStyle(
          color: AppTheme.getTextSecondary(context),
        ),
        hintStyle: TextStyle(
          color: AppTheme.getTextSecondary(context).withValues(alpha: 0.7),
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const SectionHeader({
    super.key,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon, 
          color: AppTheme.getTextSecondary(context), 
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: AppTheme.fontSizeL,
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextSecondary(context),
          ),
        ),
      ],
    );
  }
}

class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryColor.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;
    final path = Path();

    for (int i = 0; i < 3; i++) {
      final startY = size.height * (0.2 + i * 0.3);
      path.moveTo(0, startY);
      for (double x = 0; x <= size.width; x += 10) {
        final y = startY + 100 * sin((x / size.width * 2 * pi) + (i * pi / 2));
        path.lineTo(x, y);
      }
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();
      canvas.drawPath(path, paint);
      path.reset();
    }

    final circlePaint = Paint()
      ..color = AppTheme.primaryColor.withValues(alpha: 0.03)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.2), 150, circlePaint);
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.8), 200, circlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}