// clinical_history_card.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../../utils/app_theme.dart';
import '../../../../../../../controllers/historial_clinico_controller.dart';
import '../../../../../../../controllers/dashboard_page_controller.dart';

class ClinicalHistoryCard extends StatelessWidget {
  final String pacienteId;
  final String pacienteTipo; // 'asociado' o 'carga'

  const ClinicalHistoryCard({
    super.key,
    required this.pacienteId,
    required this.pacienteTipo,
  });

  @override
  Widget build(BuildContext context) {
    final HistorialClinicoController controller = Get.find<HistorialClinicoController>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Obx(() {
        // Filtrar historiales del paciente actual
        final historialesDelPaciente = controller.allHistoriales
            .where((h) =>
                h.pacienteId == pacienteId && h.pacienteTipo == pacienteTipo)
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context, historialesDelPaciente.length),
            const SizedBox(height: 16),
            _buildHistoryContent(context, historialesDelPaciente),
            if (historialesDelPaciente.length > 5) _buildScrollHint(context),
          ],
        );
      }),
    );
  }

  Widget _buildSectionHeader(BuildContext context, int historyCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.medical_information_outlined,
                color: Color(0xFF3B82F6),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Historial Clínico',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextPrimary(context),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$historyCount',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3B82F6),
                ),
              ),
            ),
            if (historyCount > 5)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: AppTheme.getTextSecondary(context),
                  size: 16,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildHistoryContent(BuildContext context, List historiales) {
    if (historiales.isEmpty) {
      return _buildEmptyState(context);
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: historiales.length > 5 ? 400 : double.infinity,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.getSurfaceColor(context),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppTheme.getBorderLight(context).withValues(alpha: 0.5),
          ),
        ),
        child: Scrollbar(
          thumbVisibility: historiales.length > 5,
          child: ListView.separated(
            shrinkWrap: true,
            physics: historiales.length > 5
                ? const AlwaysScrollableScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(8),
            itemCount: historiales.length,
            separatorBuilder: (context, index) => const SizedBox(height: 6),
            itemBuilder: (context, index) {
              final historial = historiales[index];
              return _buildHistoryItem(context, historial);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getInputBackground(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.getBorderLight(context),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.history,
            color: AppTheme.getTextSecondary(context),
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            'No hay historiales clínicos registrados',
            style: TextStyle(
              color: AppTheme.getTextSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, dynamic historial) {
    final hovered = false.obs;

    return ObxValue<RxBool>(
      (hover) => InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _goToHistorialDetail(historial),
        onHover: (value) => hover.value = value,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: hover.value
                ? AppTheme.primaryColor.withAlpha(10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              _buildHistoryAvatar(context, historial),
              const SizedBox(width: 16),
              Expanded(
                child: _buildHistoryInfo(context, historial),
              ),
              Icon(
                Icons.chevron_right,
                size: 16,
                color: AppTheme.getTextSecondary(context),
              ),
            ],
          ),
        ),
      ),
      hovered,
    );
  }

  Widget _buildHistoryAvatar(BuildContext context, dynamic historial) {
    return Stack(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.getBorderLight(context),
              width: 1,
            ),
          ),
          child: Icon(
            _getTipoConsultaIcon(historial.tipoConsulta),
            size: 24,
            color: Colors.grey.shade600,
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _getEstadoColor(historial.estado),
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).scaffoldBackgroundColor,
                width: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryInfo(BuildContext context, dynamic historial) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          historial.tipoConsultaFormateado,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextPrimary(context),
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Icon(Icons.event_outlined, size: 12, color: AppTheme.getTextSecondary(context)),
            const SizedBox(width: 4),
            Text(
              historial.fechaFormateada,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.getTextSecondary(context),
              ),
            ),
            const SizedBox(width: 12),
            Icon(Icons.person_outline, size: 12, color: AppTheme.getTextSecondary(context)),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                historial.odontologo ?? 'Sin odontólogo',
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

  Widget _buildScrollHint(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Center(
        child: Text(
          'Scrollea para ver más historiales',
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.getTextSecondary(context),
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  void _goToHistorialDetail(dynamic historial) {
    try {
      final historialController = Get.find<HistorialClinicoController>();

      if (historial is! Map<String, dynamic>) {
        historialController.selectedHistorial.value = historial;
        historialController.currentView.value = HistorialClinicoController.detalleView;
      } else {
        final historialObj = historialController.allHistoriales
            .firstWhere((h) => h.id == historial['id'], orElse: () => throw Exception('No encontrado'));
        historialController.showDetailView(historialObj);
      }

      final dashboardController = Get.find<DashboardPageController>();
      dashboardController.changeModule(3);

    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo abrir el historial clínico',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  IconData _getTipoConsultaIcon(String? tipo) {
    if (tipo == null) return Icons.medical_information_outlined;
    switch (tipo.toLowerCase()) {
      case 'consulta': return Icons.medical_information_outlined;
      case 'control':  return Icons.check_circle_outline;
      case 'urgencia':  return Icons.emergency;
      case 'tratamiento': return Icons.healing;
      default: return Icons.medical_services_outlined;
    }
  }

  Color _getEstadoColor(String? estado) {
    if (estado == null) return const Color(0xFFF59E0B);
    switch (estado.toLowerCase()) {
      case 'completado': return const Color(0xFF10B981);
      case 'pendiente':  return const Color(0xFFF59E0B);
      default:           return const Color(0xFF6B7280);
    }
  }
}