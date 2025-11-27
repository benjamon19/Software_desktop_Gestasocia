import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../utils/app_theme.dart';
import '../../../../../../models/reserva_hora.dart';
import 'reserva_detail_dialog.dart';

class MultiReservaDialog {
  static void show(BuildContext parentContext, List<ReservaHora> reservas, String hora) {
    showDialog(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.getSurfaceColor(dialogContext),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.format_list_bulleted, 
              color: AppTheme.primaryColor,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Citas de las $hora',
                style: TextStyle(
                  color: AppTheme.getTextPrimary(dialogContext),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 450,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                ...reservas.asMap().entries.map((entry) {
                  final index = entry.key;
                  final reserva = entry.value;
                  return Padding(
                    padding: EdgeInsets.only(bottom: index != reservas.length - 1 ? 6.0 : 0),
                    child: _buildReservaListItem(dialogContext, parentContext, reserva),
                  );
                }),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cerrar', 
              style: TextStyle(color: AppTheme.getTextSecondary(dialogContext))
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildReservaListItem(BuildContext dialogContext, BuildContext parentContext, ReservaHora reserva) {
    final hovered = false.obs;

    return ObxValue<RxBool>(
      (hover) => Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.pop(dialogContext); 
            
            ReservaDetailDialog.show(parentContext, reserva);
          },
          onHover: (value) => hover.value = value,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: hover.value
                  ? AppTheme.primaryColor.withAlpha(10)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hover.value 
                    ? AppTheme.primaryColor.withValues(alpha: 0.1)
                    : AppTheme.getBorderLight(dialogContext).withValues(alpha: 0.6),
              ),
            ),
            child: Row(
              children: [
                _buildAvatar(dialogContext, reserva),
                const SizedBox(width: 16),
                Expanded(child: _buildReservaInfo(dialogContext, reserva)),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: AppTheme.getTextSecondary(dialogContext),
                ),
              ],
            ),
          ),
        ),
      ),
      hovered,
    );
  }

  static Widget _buildAvatar(BuildContext context, ReservaHora reserva) {
    const double avatarSize = 36.0;
    const double iconSize = 20.0;
    const double indicatorSize = 10.0;

    return Stack(
      children: [
        Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.getBorderLight(context),
              width: 1,
            ),
          ),
          child: Icon(
            reserva.pacienteTipo == 'asociado' ? Icons.person : Icons.family_restroom,
            size: iconSize, 
            color: Colors.grey.shade600
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: indicatorSize,
            height: indicatorSize,
            decoration: BoxDecoration(
              color: _getStatusColor(reserva.estado),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.getSurfaceColor(context),
                width: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  static Widget _buildReservaInfo(BuildContext context, ReservaHora reserva) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          reserva.pacienteNombre,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextPrimary(context),
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Icon(
              Icons.medical_services_outlined, 
              size: 12, 
              color: AppTheme.getTextSecondary(context)
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                '${reserva.odontologo} • ${reserva.estado}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.getTextSecondary(context),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  static Color _getStatusColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'confirmada': return const Color(0xFF10B981);
      case 'cancelada': return const Color(0xFFEF4444);
      case 'realizada': return const Color(0xFF8B5CF6);
      default: return const Color(0xFFF59E0B);
    }
  }
}