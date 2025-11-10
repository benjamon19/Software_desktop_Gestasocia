import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../../utils/app_theme.dart';
import '../../../../../../../controllers/cargas_familiares_controller.dart';
import '../../shared/dialogs/aprobar_transferencia_dialog.dart';

class PendingActionsSection extends StatelessWidget {
  const PendingActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final CargasFamiliaresController controller = Get.find<CargasFamiliaresController>();
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 600;
    final bool isVerySmall = screenWidth < 400;

    return Container(
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
      child: Column(
        children: [
          // Header compacto
          Padding(
            padding: EdgeInsets.all(isVerySmall ? 12 : (isSmallScreen ? 14 : 16)),
            child: Row(
              children: [
                Icon(
                  Icons.pending_actions_outlined,
                  color: AppTheme.primaryColor,
                  size: isVerySmall ? 16 : (isSmallScreen ? 18 : 20),
                ),
                SizedBox(width: isVerySmall ? 8 : 12),
                Expanded(
                  child: Text(
                    isVerySmall ? 'Pendientes' : 'Transferencias Pendientes',
                    style: TextStyle(
                      fontSize: isVerySmall ? 14 : (isSmallScreen ? 15 : 16),
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getTextPrimary(context),
                    ),
                  ),
                ),
                Obx(() {
                  final count = controller.totalSolicitudesPendientes;
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isVerySmall ? 6 : 8,
                      vertical: isVerySmall ? 2 : 4,
                    ),
                    decoration: BoxDecoration(
                      color: count > 0
                          ? AppTheme.primaryColor
                          : AppTheme.getTextSecondary(context).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      count.toString(),
                      style: TextStyle(
                        fontSize: isVerySmall ? 10 : (isSmallScreen ? 11 : 12),
                        fontWeight: FontWeight.w600,
                        color: count > 0
                            ? Colors.white
                            : AppTheme.getTextSecondary(context),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          // Línea divisoria sutil
          Container(
            height: 1,
            margin: EdgeInsets.symmetric(horizontal: isVerySmall ? 12 : 16),
            color: AppTheme.getTextSecondary(context).withValues(alpha: 0.1),
          ),

          // Lista de solicitudes de transferencia
          Obx(() {
            if (controller.solicitudesTransferencia.isEmpty) {
              return Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: isVerySmall ? 40 : 48,
                        color: AppTheme.getTextSecondary(context).withValues(alpha: 0.3),
                      ),
                      SizedBox(height: isVerySmall ? 8 : 12),
                      Text(
                        isVerySmall
                            ? 'Sin pendientes'
                            : 'No hay transferencias pendientes',
                        style: TextStyle(
                          fontSize: isVerySmall ? 12 : 14,
                          color: AppTheme.getTextSecondary(context),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            return Expanded(
              child: ListView.separated(
                padding: EdgeInsets.all(isVerySmall ? 8 : (isSmallScreen ? 12 : 16)),
                itemCount: controller.solicitudesTransferencia.length,
                separatorBuilder: (context, index) =>
                    SizedBox(height: isVerySmall ? 6 : 8),
                itemBuilder: (context, index) {
                  final solicitud = controller.solicitudesTransferencia[index];
                  return _buildTransferenciaItem(
                    context: context,
                    solicitud: solicitud,
                    controller: controller,
                    isSmallScreen: isSmallScreen,
                    isVerySmall: isVerySmall,
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTransferenciaItem({
    required BuildContext context,
    required solicitud,
    required CargasFamiliaresController controller,
    required bool isSmallScreen,
    required bool isVerySmall,
  }) {
    final hovered = false.obs;

    return ObxValue<RxBool>(
      (hover) => InkWell(
        onTap: () {
          AprobarTransferenciaDialog.show(context, solicitud, controller);
        },
        onHover: (value) => hover.value = value,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.all(isVerySmall ? 8 : (isSmallScreen ? 10 : 12)),
          decoration: BoxDecoration(
            color: hover.value
                ? const Color(0xFF10B981).withValues(alpha: 0.05)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: hover.value
                  ? const Color(0xFF10B981).withValues(alpha: 0.3)
                  : AppTheme.getBorderLight(context),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nombre de la carga
              Row(
                children: [
                  Container(
                    width: isVerySmall ? 28 : (isSmallScreen ? 32 : 36),
                    height: isVerySmall ? 28 : (isSmallScreen ? 32 : 36),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.swap_horiz,
                      color: const Color(0xFF10B981),
                      size: isVerySmall ? 14 : (isSmallScreen ? 16 : 18),
                    ),
                  ),
                  SizedBox(width: isVerySmall ? 8 : 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          solicitud.cargaNombre,
                          style: TextStyle(
                            fontSize:
                                isVerySmall ? 12 : (isSmallScreen ? 13 : 14),
                            fontWeight: FontWeight.w600,
                            color: AppTheme.getTextPrimary(context),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (!isVerySmall) ...[
                          const SizedBox(height: 2),
                          Text(
                            solicitud.cargaRut,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.getTextSecondary(context),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: isSmallScreen ? 14 : 16,
                    color: AppTheme.getTextSecondary(context),
                  ),
                ],
              ),

              if (!isVerySmall) ...[
                SizedBox(height: isSmallScreen ? 8 : 10),

                // Origen y Destino
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'De:',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppTheme.getTextSecondary(context),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            solicitud.asociadoOrigenNombre,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.getTextPrimary(context),
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward,
                      size: 12,
                      color: AppTheme.getTextSecondary(context),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Para:',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppTheme.getTextSecondary(context),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            solicitud.asociadoDestinoNombre,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF10B981),
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
      hovered,
    );
  }
}