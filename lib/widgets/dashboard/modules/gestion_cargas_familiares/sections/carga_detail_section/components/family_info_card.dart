import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../../utils/app_theme.dart';
import '../../../../../../../controllers/cargas_familiares_controller.dart';

class FamilyInfoCard extends StatelessWidget {
  final Map<String, dynamic> carga;

  const FamilyInfoCard({
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
            Icons.contact_phone_outlined,
            color: Color(0xFF10B981),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Información de Contacto',
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
        
        _buildInfoItem(
          context,
          'Dirección',
          direccion.isNotEmpty ? direccion : 'No registrada',
          Icons.location_on_outlined,
          const Color(0xFFEF4444),
          isEmpty: direccion.isEmpty,
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
}