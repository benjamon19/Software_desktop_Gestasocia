import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../../utils/app_theme.dart';
import '../../../../../../../models/carga_familiar.dart';
import '../../../../../../../controllers/asociados_controller.dart';
import '../../../shared/widgets/section_title.dart';

class FamilyInfoCard extends StatelessWidget {
  final CargaFamiliar carga; // ⭐ CAMBIAR de Map a CargaFamiliar

  const FamilyInfoCard({super.key, required this.carga});

  @override
  Widget build(BuildContext context) {
    // Manejo seguro de datos anidados
    final contactoEmergencia = carga.contactoEmergencia ?? {};
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: 'Información Familiar'),
          const SizedBox(height: 16),
          
          // Asociado Titular
          _buildInfoItem(
            context, 
            'Asociado Titular', 
            _getAsociadoNombre(carga.asociadoId), 
            Icons.person_outlined
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  context, 
                  'Parentesco', 
                  carga.parentesco, 
                  Icons.family_restroom_outlined
                )
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoItem(
                  context, 
                  'Estado', 
                  carga.estado, 
                  Icons.toggle_on_outlined
                )
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Solo mostrar contacto de emergencia si existe
          if (contactoEmergencia.isNotEmpty) ...[
            const SectionTitle(title: 'Contacto de Emergencia'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.getInputBackground(context),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.getBorderLight(context)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${contactoEmergencia['nombre']?.toString() ?? 'Sin nombre'} (${contactoEmergencia['relacion']?.toString() ?? 'Sin relación'})',
                    style: TextStyle(
                      fontSize: 14, 
                      fontWeight: FontWeight.w600, 
                      color: AppTheme.getTextPrimary(context)
                    )
                  ),
                  const SizedBox(height: 4),
                  Text(
                    contactoEmergencia['telefono']?.toString() ?? 'Sin teléfono',
                    style: TextStyle(
                      fontSize: 13, 
                      color: AppTheme.getTextSecondary(context)
                    )
                  ),
                ],
              ),
            ),
          ] else ...[
            // Mensaje cuando no hay contacto de emergencia
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.getInputBackground(context),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.getBorderLight(context)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline, 
                    size: 16, 
                    color: AppTheme.getTextSecondary(context)
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Sin contacto de emergencia registrado',
                    style: TextStyle(
                      fontSize: 13, 
                      color: AppTheme.getTextSecondary(context)
                    )
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getAsociadoNombre(String? asociadoId) {
    if (asociadoId == null || asociadoId.isEmpty) return 'Sin titular';
    try {
      final AsociadosController asociadosController = Get.find<AsociadosController>();
      final asociado = asociadosController.getAsociadoById(asociadoId);
      if (asociado != null) return asociado.nombreCompleto;
    } catch (e) {
      // Error silencioso
    }
    return 'Titular: ${asociadoId.substring(0, asociadoId.length > 8 ? 8 : asociadoId.length)}...';
  }

  Widget _buildInfoItem(BuildContext context, String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getInputBackground(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.getBorderLight(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppTheme.getTextSecondary(context)),
              const SizedBox(width: 8),
              Text(
                label, 
                style: TextStyle(
                  fontSize: 12, 
                  fontWeight: FontWeight.w500, 
                  color: AppTheme.getTextSecondary(context)
                )
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value, 
            style: TextStyle(
              fontSize: 14, 
              fontWeight: FontWeight.w600, 
              color: AppTheme.getTextPrimary(context)
            )
          ),
        ],
      ),
    );
  }
}