import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../utils/app_theme.dart';
import '../../../../../../controllers/cargas_familiares_controller.dart';
import '../../../../../../models/transferencia_solicitud.dart';

class AprobarTransferenciaDialog {
  static void show(
    BuildContext context,
    TransferenciaSolicitud solicitud,
    CargasFamiliaresController controller,
  ) {
    final motivoRechazoController = TextEditingController();
    final isLoading = false.obs;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.getSurfaceColor(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.swap_horiz,
              color: Color(0xFF10B981),
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Aprobar Transferencia',
                style: TextStyle(
                  color: AppTheme.getTextPrimary(context),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Información de la carga
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.family_restroom,
                          color: const Color(0xFF10B981),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Carga Familiar',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.getTextSecondary(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      solicitud.cargaNombre,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.getTextPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'RUT: ${solicitud.cargaRut}',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.getTextSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Origen
              _buildInfoRow(
                context,
                'Asociado Actual',
                solicitud.asociadoOrigenNombre,
                Icons.person_outline,
                Colors.grey,
              ),

              const SizedBox(height: 12),

              // Flecha indicador
              Center(
                child: Icon(
                  Icons.arrow_downward,
                  color: AppTheme.getTextSecondary(context),
                  size: 24,
                ),
              ),

              const SizedBox(height: 12),

              // Destino
              _buildInfoRow(
                context,
                'Nuevo Asociado',
                solicitud.asociadoDestinoNombre,
                Icons.person,
                const Color(0xFF10B981),
              ),

              const SizedBox(height: 20),

              // Información adicional
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.blue.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Al aprobar, la carga será transferida al nuevo asociado inmediatamente.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.getTextPrimary(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          // Botón Rechazar
          TextButton.icon(
            onPressed: isLoading.value
                ? null
                : () {
                    _showRechazarDialog(context, solicitud, controller, motivoRechazoController);
                  },
            icon: const Icon(Icons.close, size: 18),
            label: const Text('Rechazar'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),
          
          // Botón Aprobar
          Obx(() => ElevatedButton.icon(
            onPressed: isLoading.value
                ? null
                : () async {
                    isLoading.value = true;
                    final success = await controller.aprobarTransferencia(solicitud);
                    isLoading.value = false;

                    if (success && context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
            icon: isLoading.value
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.check, size: 18),
            label: Text(isLoading.value ? 'Aprobando...' : 'Aprobar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          )),
        ],
      ),
    );
  }

  static Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.getInputBackground(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.getBorderLight(context)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.getTextSecondary(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getTextPrimary(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static void _showRechazarDialog(
    BuildContext context,
    TransferenciaSolicitud solicitud,
    CargasFamiliaresController controller,
    TextEditingController motivoController,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.getSurfaceColor(dialogContext),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text('Rechazar Transferencia'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Por qué deseas rechazar esta transferencia?',
              style: TextStyle(
                color: AppTheme.getTextPrimary(dialogContext),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: motivoController,
              maxLines: 3,
              style: TextStyle(color: AppTheme.getTextPrimary(dialogContext)),
              decoration: InputDecoration(
                labelText: 'Motivo del rechazo',
                hintText: 'Escribe el motivo...',
                labelStyle: TextStyle(color: AppTheme.getTextSecondary(dialogContext)),
                hintStyle: TextStyle(
                  color: AppTheme.getTextSecondary(dialogContext).withValues(alpha: 0.5),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppTheme.getBorderLight(dialogContext)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (motivoController.text.trim().isEmpty) {
                Get.snackbar(
                  'Error',
                  'Debes especificar un motivo',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Get.theme.colorScheme.error.withValues(alpha: 0.8),
                  colorText: Get.theme.colorScheme.onError,
                );
                return;
              }

              Navigator.of(dialogContext).pop(); // Cerrar diálogo de motivo
              Navigator.of(context).pop(); // Cerrar diálogo principal

              await controller.rechazarTransferencia(solicitud, motivoController.text.trim());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Rechazar'),
          ),
        ],
      ),
    );
  }
}