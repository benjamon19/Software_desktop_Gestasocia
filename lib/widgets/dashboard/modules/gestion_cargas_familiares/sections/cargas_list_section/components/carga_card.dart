import 'package:flutter/material.dart';
import '../../../../../../../utils/app_theme.dart';

class CargaCard extends StatelessWidget {
  final Map<String, dynamic> carga;
  final VoidCallback onTap;

  const CargaCard({super.key, required this.carga, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.getInputBackground(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.getBorderLight(context)),
          ),
          child: Row(
            children: [
              _buildAvatar(),
              const SizedBox(width: 16),
              Expanded(child: _buildInfo(context)),
              _buildStatus(context),
              Icon(Icons.chevron_right, color: AppTheme.getTextSecondary(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: _getParentescoColor().withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(color: _getParentescoColor().withValues(alpha: 0.3)),
      ),
      child: Icon(_getParentescoIcon(), color: _getParentescoColor(), size: 24),
    );
  }

  Widget _buildInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${carga['nombre']} ${carga['apellido']}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextPrimary(context),
          ),
        ),
        Text(
          '${carga['parentesco']} • ${carga['edad']} años',
          style: TextStyle(fontSize: 14, color: _getParentescoColor()),
        ),
        Text(
          'Titular: ${carga['titular']}',
          style: TextStyle(fontSize: 13, color: AppTheme.getTextSecondary(context)),
        ),
        Row(
          children: [
            Icon(Icons.badge, size: 12, color: AppTheme.getTextSecondary(context)),
            const SizedBox(width: 4),
            Text(carga['rut'], style: TextStyle(fontSize: 12, color: AppTheme.getTextSecondary(context))),
            const SizedBox(width: 12),
            Icon(Icons.card_membership, size: 12, color: AppTheme.primaryColor),
            const SizedBox(width: 4),
            Text(carga['plan'], style: TextStyle(fontSize: 12, color: AppTheme.primaryColor)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatus(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getEstadoColor().withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _getEstadoColor().withValues(alpha: 0.3)),
          ),
          child: Text(
            carga['estado'],
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _getEstadoColor()),
          ),
        ),
        if (carga['Urgencias'].isNotEmpty) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${carga['Urgencias'].length}',
              style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ],
    );
  }

  IconData _getParentescoIcon() {
    switch (carga['parentesco'].toLowerCase()) {
      case 'hijo': case 'hija': return Icons.child_care;
      case 'cónyuge': return Icons.favorite;
      case 'padre': case 'madre': return Icons.elderly;
      default: return Icons.person;
    }
  }

  Color _getParentescoColor() {
    switch (carga['parentesco'].toLowerCase()) {
      case 'hijo': case 'hija': return const Color(0xFF10B981);
      case 'cónyuge': return const Color(0xFFEC4899);
      case 'padre': case 'madre': return const Color(0xFF8B5CF6);
      default: return const Color(0xFF6B7280);
    }
  }

  Color _getEstadoColor() {
    switch (carga['estado'].toLowerCase()) {
      case 'activa': return const Color(0xFF10B981);
      case 'suspendida': return const Color(0xFFF59E0B);
      default: return const Color(0xFFEF4444);
    }
  }
}