import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../utils/app_theme.dart';
import '../../../../../../controllers/historial_cargas_controller.dart';
import '../../../../../../models/historial_carga_cambio.dart';

class HistorialCargaDialog {
  static void show(
    BuildContext context, {
    required String cargaFamiliarId,
    required String nombreCarga,
  }) {
    final HistorialCargasController historialController = Get.put(HistorialCargasController());
    historialController.cargarHistorialCarga(cargaFamiliarId);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.getSurfaceColor(dialogContext),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Row(
          children: [
            Icon(
              Icons.history,
              color: Color (0xFF10B981),
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Historial de Cambios',
                    style: TextStyle(
                      color: AppTheme.getTextPrimary(dialogContext),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    nombreCarga,
                    style: TextStyle(
                      color: AppTheme.getTextSecondary(dialogContext),
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 700,
          height: 500,
          child: Obx(() {
            if (historialController.isLoading.value) {
              return Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primaryColor,
                ),
              );
            }

            if (historialController.historialCambios.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history_toggle_off,
                      size: 64,
                      color: AppTheme.getTextSecondary(dialogContext)
                          .withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay cambios registrados',
                      style: TextStyle(
                        color: AppTheme.getTextSecondary(dialogContext),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: historialController.historialCambios.length,
              itemBuilder: (context, index) {
                final cambio = historialController.historialCambios[index];
                return _buildHistorialItem(dialogContext, cambio, index == 0);
              },
            );
          }),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Cerrar',
              style: TextStyle(
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildHistorialItem(
    BuildContext context,
    HistorialCargaCambio cambio,
    bool isFirst,
  ) {
    final color = HistorialCargaCambio.getColorTipoAccion(cambio.tipoAccion);
    final icon = HistorialCargaCambio.getIconoTipoAccion(cambio.tipoAccion);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icono
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),

            // Contenido
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Descripción
                  Text(
                    cambio.descripcion,
                    style: TextStyle(
                      color: AppTheme.getTextPrimary(context),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Usuario
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 16,
                        color: AppTheme.getTextSecondary(context),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        cambio.usuarioNombre,
                        style: TextStyle(
                          color: AppTheme.getTextSecondary(context),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Fecha y hora
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: AppTheme.getTextSecondary(context),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        cambio.fechaFormateada,
                        style: TextStyle(
                          color: AppTheme.getTextSecondary(context),
                          fontSize: 13,
                        ),
                      ),
                      if (isFirst) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Reciente',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  // ========== SECCIÓN DE CAMBIOS DETALLADOS ==========
                  
                  if (cambio.valoresAnteriores != null &&
                      cambio.valoresNuevos != null &&
                      cambio.valoresAnteriores!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.getTextSecondary(context)
                            .withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: color.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.compare_arrows,
                                size: 16,
                                color: color,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Cambios realizados:',
                                style: TextStyle(
                                  color: color,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...cambio.valoresNuevos!.entries.map((entry) {
                            final campo = entry.key;
                            final valorAnterior = cambio.valoresAnteriores![campo];
                            final valorNuevo = entry.value;
                            
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    HistorialCargaCambio.getNombreCampo(campo),
                                    style: TextStyle(
                                      color: AppTheme.getTextPrimary(context),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      // Valor anterior
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.red.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(
                                              color: Colors.red.withValues(alpha: 0.3),
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.remove_circle_outline,
                                                size: 14,
                                                color: Colors.red[700],
                                              ),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  valorAnterior?.toString() ?? 'N/A',
                                                  style: TextStyle(
                                                    color: Colors.red[700],
                                                    fontSize: 11,
                                                    decoration: TextDecoration.lineThrough,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                        child: Icon(
                                          Icons.arrow_forward,
                                          size: 16,
                                          color: AppTheme.getTextSecondary(context),
                                        ),
                                      ),
                                      
                                      // Valor nuevo
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.green.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(
                                              color: Colors.green.withValues(alpha: 0.3),
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.add_circle_outline,
                                                size: 14,
                                                color: Colors.green[700],
                                              ),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  valorNuevo?.toString() ?? 'N/A',
                                                  style: TextStyle(
                                                    color: Colors.green[700],
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          })
                        ],
                      ),
                    ),
                  ],

                  // Mostrar datos adicionales (para creación, etc.)
                  if (cambio.datosAdicionales != null &&
                      cambio.datosAdicionales!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: color.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 16,
                                color: color,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Detalles:',
                                style: TextStyle(
                                  color: color,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...cambio.datosAdicionales!.entries.map((entry) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${_formatearNombreCampo(entry.key)}: ',
                                    style: TextStyle(
                                      color: AppTheme.getTextSecondary(context),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      entry.value.toString(),
                                      style: TextStyle(
                                        color: AppTheme.getTextPrimary(context),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          })
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper para formatear nombres de campos
  static String _formatearNombreCampo(String campo) {
    const Map<String, String> nombres = {
      'nombreCompleto': 'Nombre Completo',
      'rut': 'RUT',
      'parentesco': 'Parentesco',
      'edad': 'Edad',
    };
    
    return nombres[campo] ?? campo;
  }
}