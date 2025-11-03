import 'package:flutter/material.dart';
import '../../../../../../utils/app_theme.dart';

class EmptyStateSection extends StatelessWidget {
  const EmptyStateSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildMainIcon(context),
          const SizedBox(height: 32),
          _buildTitle(context),
          const SizedBox(height: 16),
          _buildActionSuggestions(context),
        ],
      ),
    );
  }

  Widget _buildMainIcon(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.08),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.people_outline,
        size: 64,
        color: AppTheme.primaryColor.withValues(alpha: 0.7),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      'No hay asociados disponibles',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppTheme.getTextPrimary(context),
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildActionSuggestions(BuildContext context) {
    return Column(
      children: [
        Text(
          'No se encontró ningún asociado o aún no hay registros',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextPrimary(context),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Container(
          constraints: const BoxConstraints(maxWidth: 200),
          child: Text(
            'Usa el botón flotante para registrar un asociado',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.getTextSecondary(context),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}