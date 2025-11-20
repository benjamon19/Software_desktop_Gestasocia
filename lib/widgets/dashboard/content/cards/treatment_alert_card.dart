import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/app_theme.dart';
import '../../../../controllers/historial_clinico_controller.dart';
import '../../../../controllers/asociados_controller.dart';
import '../../../../controllers/cargas_familiares_controller.dart';
import '../../../../controllers/dashboard_page_controller.dart';
import '../../../../models/historial_clinico.dart';

class TreatmentAlertCard extends StatelessWidget {
  final bool isCompact; // 👈 Permite forzar modo compacto desde ChartsGridSection

  const TreatmentAlertCard({super.key, this.isCompact = false});

  @override
  Widget build(BuildContext context) {
    final HistorialClinicoController controller = Get.find<HistorialClinicoController>();
    
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bool isSmallScreen = screenWidth < 600;
    final bool isMediumScreen = screenWidth >= 600 && screenWidth < 1000;
    final bool isShortScreen = screenHeight < 700;
    final bool isVeryShortScreen = screenHeight < 600;
    final bool useCompactMode = isCompact || isVeryShortScreen;

    double cardPadding = useCompactMode ? 8 : (isShortScreen ? 10 : 16);
    
    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.black.withValues(alpha: 0.3) 
                : Colors.grey.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Obx(() {
        final allUrgencias = controller.urgenciasPendientes;
        final displayUrgencias = allUrgencias.take(10).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAdaptiveHeader(context, allUrgencias.length, isSmallScreen, useCompactMode),
            
            SizedBox(height: useCompactMode ? 8 : 12),
            
            Expanded(
              child: displayUrgencias.isEmpty
                  ? _buildEmptyState(context, useCompactMode)
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: displayUrgencias.length,
                      itemBuilder: (context, index) {
                        final urgencia = displayUrgencias[index];
                        final info = controller.getPacienteInfoForDisplay(urgencia);
                        
                        return _buildAdaptiveAlertItem(
                          context, 
                          urgencia,
                          info['nombre'] ?? 'Desconocido',
                          isSmallScreen,
                          isMediumScreen,
                          useCompactMode,
                        );
                      },
                    ),
            ),
            
            if (!isVeryShortScreen && allUrgencias.isNotEmpty) ...[
              SizedBox(height: useCompactMode ? 6 : 8),
              _buildAdaptiveFooter(context, controller, isSmallScreen, allUrgencias.length > 10),
            ]
          ],
        );
      }),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool compact) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: compact ? 28 : 32,
            color: AppTheme.getTextSecondary(context).withValues(alpha: 0.3),
          ),
          SizedBox(height: compact ? 6 : 8),
          Text(
            compact ? 'Sin urgencias' : 'Sin urgencias pendientes',
            style: TextStyle(
              fontSize: compact ? 11 : 12,
              color: AppTheme.getTextSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdaptiveHeader(BuildContext context, int count, bool isSmallScreen, bool compact) {
    return Row(
      children: [
        Text(
          isSmallScreen ? 'Urgencias' : 'Urgencias Pendientes',
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextPrimary(context),
          ),
        ),
        const Spacer(),
        if (count > 0)
          Container(
            padding: EdgeInsets.symmetric(horizontal: compact ? 5 : 6, vertical: compact ? 1 : 2),
            decoration: BoxDecoration(
              color: Color(0xFFEF4444).withValues(alpha: 0.1), // ✅ sin const
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: isSmallScreen ? 10 : 11,
                color: const Color(0xFFEF4444),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAdaptiveFooter(BuildContext context, HistorialClinicoController controller, bool isSmallScreen, bool showSeeAll) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => _showAllUrgenciesDialog(context, controller),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          showSeeAll ? (isSmallScreen ? 'Ver más →' : 'Ver todas →') : 'Ver detalles →',
          style: TextStyle(
            fontSize: isSmallScreen ? 10 : 11,
            color: const Color(0xFF3B82F6),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildAdaptiveAlertItem(
    BuildContext context, 
    HistorialClinico urgencia,
    String pacienteNombre,
    bool isSmallScreen,
    bool isMediumScreen,
    bool compact,
  ) {
    final daysOverdue = DateTime.now().difference(urgencia.fecha).inDays;
    Color urgencyColor = daysOverdue > 3 ? const Color(0xFFEF4444) : const Color(0xFFF59E0B);
    
    double verticalPadding = compact ? 2 : (isSmallScreen ? 3 : 4);
    double daysColumnWidth = compact ? 30 : (isSmallScreen ? 35 : 40);
    double daysSize = compact ? 9 : (isSmallScreen ? 10 : 11);
    double contentSize = compact ? 10 : (isSmallScreen ? 11 : 12);
    double horizontalSpacing = compact ? 6 : (isSmallScreen ? 8 : 12);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _goToPatientProfile(urgencia.pacienteId, urgencia.pacienteTipo),
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: daysColumnWidth,
                child: Text(
                  '${daysOverdue}d',
                  style: TextStyle(
                    fontSize: daysSize,
                    fontWeight: FontWeight.w700,
                    color: urgencyColor,
                  ),
                ),
              ),
              SizedBox(width: horizontalSpacing),
              Expanded(
                child: _buildAdaptiveAlertContent(
                  context,
                  pacienteNombre,
                  urgencia.motivoPrincipal,
                  contentSize,
                  isMediumScreen,
                  compact,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdaptiveAlertContent(
    BuildContext context,
    String patientName,
    String message,
    double fontSize,
    bool isMediumScreen,
    bool compact,
  ) {
    if (compact) {
      return Text(
        patientName,
        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500, color: AppTheme.getTextPrimary(context)),
        maxLines: 1, overflow: TextOverflow.ellipsis,
      );
    } else if (isMediumScreen) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(patientName, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500, color: AppTheme.getTextPrimary(context)), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(message, style: TextStyle(fontSize: fontSize - 1, color: AppTheme.getTextSecondary(context)), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      );
    } else {
      return RichText(
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          style: TextStyle(fontSize: fontSize, color: AppTheme.getTextPrimary(context)),
          children: [
            TextSpan(text: patientName, style: const TextStyle(fontWeight: FontWeight.w500)),
            TextSpan(text: ' • $message', style: TextStyle(color: AppTheme.getTextSecondary(context), fontWeight: FontWeight.normal)),
          ],
        ),
      );
    }
  }

  void _showAllUrgenciesDialog(BuildContext context, HistorialClinicoController controller) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.getSurfaceColor(dialogContext),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber, color: Color(0xFFEF4444)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Todas las Urgencias Pendientes',
                style: TextStyle(
                  color: AppTheme.getTextPrimary(dialogContext),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            IconButton(
              onPressed: () => Navigator.pop(dialogContext),
              icon: Icon(Icons.close, color: AppTheme.getTextSecondary(dialogContext)),
            ),
          ],
        ),
        content: SizedBox(
          width: 500,
          height: 500,
          child: Obx(() {
            final allUrgencias = controller.urgenciasPendientes;

            if (allUrgencias.isEmpty) {
              return Center(
                child: Text(
                  'No hay urgencias pendientes.',
                  style: TextStyle(color: AppTheme.getTextSecondary(dialogContext)),
                ),
              );
            }

            return ListView.separated(
              itemCount: allUrgencias.length,
              separatorBuilder: (ctx, i) => 
                Divider(height: 1, color: AppTheme.getBorderLight(dialogContext).withValues(alpha: 0.5)),
              itemBuilder: (ctx, index) {
                final urgencia = allUrgencias[index];
                final info = controller.getPacienteInfoForDisplay(urgencia);
                final daysOverdue = DateTime.now().difference(urgencia.fecha).inDays;
                
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  onTap: () {
                    Navigator.pop(dialogContext);
                    _goToPatientProfile(urgencia.pacienteId, urgencia.pacienteTipo);
                  },
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(0xFFEF4444).withValues(alpha: 0.1), // ✅
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${daysOverdue}d',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFEF4444),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  title: Text(
                    info['nombre'] ?? 'Desconocido',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getTextPrimary(dialogContext),
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    urgencia.motivoPrincipal,
                    style: TextStyle(
                      color: AppTheme.getTextSecondary(dialogContext),
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                );
              },
            );
          }),
        ),
      ),
    );
  }

  void _goToPatientProfile(String pacienteId, String pacienteTipo) {
    try {
      if (pacienteTipo == 'asociado') {
        final asociadosController = Get.find<AsociadosController>();
        final asociado = asociadosController.getAsociadoById(pacienteId);
        if (asociado != null) {
          asociadosController.selectedAsociado.value = asociado;
          Get.find<DashboardPageController>().changeModule(1);
        }
      } else if (pacienteTipo == 'carga') {
        final cargasController = Get.find<CargasFamiliaresController>();
        final carga = cargasController.getCargaById(pacienteId);
        if (carga != null) {
          final cargaMap = {
            'id': carga.id,
            'nombre': carga.nombre,
            'apellido': carga.apellido,
            'nombreCompleto': carga.nombreCompleto,
            'rut': carga.rut,
            'rutFormateado': carga.rutFormateado,
            'parentesco': carga.parentesco,
            'edad': carga.edad,
            'fechaNacimiento': carga.fechaNacimientoFormateada,
            'fechaCreacion': carga.fechaCreacionFormateada,
            'estado': carga.estado,
            'isActive': carga.isActive,
            'asociadoId': carga.asociadoId,
          };
          cargasController.selectCarga(cargaMap);
          Get.find<DashboardPageController>().changeModule(2);
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'No se pudo abrir el perfil del paciente');
    }
  }
}