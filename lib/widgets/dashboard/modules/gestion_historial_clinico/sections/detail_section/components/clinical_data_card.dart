import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../../utils/app_theme.dart';
import '../../../../../../../controllers/historial_clinico_controller.dart';

class ClinicalDataCard extends StatelessWidget {
  final Map<String, dynamic> historial;

  const ClinicalDataCard({
    super.key,
    required this.historial,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HistorialClinicoController>();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        border: Border(
          left: BorderSide(
            color: AppTheme.getBorderLight(context).withValues(alpha: 0.3),
            width: 1,
          ),
          right: BorderSide(
            color: AppTheme.getBorderLight(context).withValues(alpha: 0.3),
            width: 1,
          ),
          bottom: BorderSide(
            color: AppTheme.getBorderLight(context).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.medical_services_outlined,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Datos Clínicos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getTextPrimary(context),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Contenido - REACTIVO
          Obx(() {
            final currentHistorial = controller.selectedHistorial.value;
            if (currentHistorial == null) {
              return const SizedBox();
            }
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Fila 1: Diagnóstico y Tratamiento
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        context,
                        'Diagnóstico',
                        currentHistorial.diagnostico ?? 'No especificado',
                        Icons.medical_information_outlined,
                        const Color(0xFF3B82F6),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoItem(
                        context,
                        'Tratamiento Realizado',
                        currentHistorial.tratamientoRealizado ?? 'No especificado',
                        Icons.healing_outlined,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Fila 2: Diente y Alergias
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        context,
                        'Diente(s) Tratado(s)',
                        currentHistorial.dienteTratado ?? 'No especificado',
                        Icons.format_list_numbered_outlined,
                        Colors.purple,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoItem(
                        context,
                        'Alergias',
                        currentHistorial.alergias ?? 'Ninguna registrada',
                        Icons.warning_amber_outlined,
                        Colors.red,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Fila 3: Medicamentos y Próxima Cita
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        context,
                        'Medicamentos Actuales',
                        currentHistorial.medicamentosActuales ?? 'Ninguno registrado',
                        Icons.medication_outlined,
                        Colors.teal,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoItem(
                        context,
                        'Próxima Cita',
                        currentHistorial.proximaCitaFormateada,
                        Icons.calendar_today_outlined,
                        Colors.indigo,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Fila 4: Observaciones (ancho completo)
                _buildInfoItem(
                  context,
                  'Observaciones',
                  currentHistorial.observacionesOdontologo ?? 'Sin observaciones',
                  Icons.notes_outlined,
                  Colors.orange,
                ),
                
                const SizedBox(height: 16),
                
                // Fila 5: Costo y Motivo
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        context,
                        'Costo del Tratamiento',
                        currentHistorial.costoTratamiento != null 
                            ? '\$${currentHistorial.costoTratamiento!.toStringAsFixed(0)}'
                            : 'No especificado',
                        Icons.attach_money_outlined,
                        Colors.amber,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoItem(
                        context,
                        'Motivo Principal',
                        currentHistorial.motivoPrincipal,
                        Icons.description_outlined,
                        const Color(0xFF8B5CF6),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.getBorderLight(context).withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getTextSecondary(context),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextPrimary(context),
              height: 1.3,
            ),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}