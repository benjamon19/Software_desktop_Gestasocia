import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../../utils/app_theme.dart';
import '../../../../../../../controllers/cargas_familiares_controller.dart';
import '../../../../../../../controllers/asociados_controller.dart';

class PersonalInfoCard extends StatelessWidget {
  final Map<String, dynamic> carga;

  const PersonalInfoCard({
    super.key,
    required this.carga,
  });

  @override
  Widget build(BuildContext context) {
    final CargasFamiliaresController controller = Get.find<CargasFamiliaresController>();
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(context),
          const SizedBox(height: 20),
          Obx(() {
            final currentCarga = controller.selectedCarga.value;
            if (currentCarga == null) {
              return const SizedBox();
            }
            return _buildInfoGrid(context, currentCarga);
          }),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.family_restroom_outlined,
            color: Color(0xFF10B981),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Información Personal',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.getTextPrimary(context),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoGrid(BuildContext context, dynamic currentCarga) {
    final email = currentCarga.email ?? '';
    final telefono = currentCarga.telefono ?? '';
    final direccion = currentCarga.direccion ?? '';

    return Column(
      children: [
        // Primera fila: Nombre Completo y RUT
        Row(
          children: [
            Expanded(
              child: _buildInfoItem(
                context,
                'Nombre Completo',
                currentCarga.nombreCompleto,
                Icons.person_outline,
                const Color(0xFF10B981),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInfoItem(
                context,
                'RUT',
                _formatearRut(currentCarga.rut),
                Icons.badge_outlined,
                Colors.blue,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Segunda fila: Email y Teléfono
        Row(
          children: [
            Expanded(
              child: _buildInfoItem(
                context,
                'Email',
                email.isNotEmpty ? email : 'No registrado',
                Icons.email_outlined,
                const Color(0xFF3B82F6),
                isEmpty: email.isEmpty,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInfoItem(
                context,
                'Teléfono',
                telefono.isNotEmpty ? telefono : 'No registrado',
                Icons.phone_outlined,
                const Color(0xFF10B981),
                isEmpty: telefono.isEmpty,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Tercera fila: Fecha de Nacimiento y Edad
        Row(
          children: [
            Expanded(
              child: _buildInfoItem(
                context,
                'Fecha de Nacimiento',
                currentCarga.fechaNacimientoFormateada,
                Icons.cake_outlined,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInfoItem(
                context,
                'Edad',
                '${currentCarga.edad} años',
                Icons.timeline_outlined,
                Colors.purple,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Cuarta fila: Parentesco y Asociado Titular
        Row(
          children: [
            Expanded(
              child: _buildInfoItem(
                context,
                'Parentesco',
                currentCarga.parentesco,
                Icons.favorite_outline,
                Colors.pink,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInfoItem(
                context,
                'Asociado Titular',
                _getAsociadoNombre(currentCarga.asociadoId),
                Icons.account_circle_outlined,
                const Color(0xFF10B981),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Quinta fila: Dirección (ocupa toda la fila)
        _buildInfoItem(
          context,
          'Dirección',
          direccion.isNotEmpty ? direccion : 'No registrada',
          Icons.location_on_outlined,
          const Color(0xFFEF4444),
          isEmpty: direccion.isEmpty,
        ),
        
        const SizedBox(height: 16),
        
        // Sexta fila: Fecha de Registro
        _buildInfoItem(
          context,
          'Fecha de Registro',
          currentCarga.fechaCreacionFormateada,
          Icons.calendar_today_outlined,
          Colors.teal,
        ),
      ],
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color iconColor, {
    bool isEmpty = false,
  }) {
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
              fontWeight: isEmpty ? FontWeight.normal : FontWeight.w600,
              color: isEmpty
                  ? AppTheme.getTextSecondary(context).withValues(alpha: 0.5)
                  : AppTheme.getTextPrimary(context),
              fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _formatearRut(String rutRaw) {
    final clean = rutRaw.replaceAll(RegExp(r'[^0-9kK]'), '').toUpperCase();
    if (clean.isEmpty) return '';
    if (clean.length <= 1) return clean;
    
    String cuerpo = clean.substring(0, clean.length - 1);
    String dv = clean.substring(clean.length - 1);
    
    cuerpo = cuerpo.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    
    return '$cuerpo-$dv';
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
    return 'Titular desconocido';
  }
}