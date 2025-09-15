import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../utils/app_theme.dart';
import '../../../../../../controllers/asociados_controller.dart';
import '../components/rut_search_field.dart';

class SearchSection extends StatelessWidget {
  final AsociadosController controller;

  const SearchSection({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSectionHeader(context),
        const SizedBox(height: 12),
        _buildSearchControls(context),
        const SizedBox(height: 8)
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 8),
        Text(
          'Buscador',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextPrimary(context),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchControls(BuildContext context) {
    return Obx(() => Row(
      children: [
        // Campo principal de búsqueda (más ancho)
        Expanded(
          flex: 5,
          child: RutSearchField(
            key: controller.searchFieldKey, // NUEVO: Key para acceso externo
            onSearch: controller.searchAsociado,
            onChanged: (query) => controller.onSearchQueryChanged(query), // NUEVO: Búsqueda en tiempo real
            isLoading: controller.isLoading.value,
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Menú desplegable "Advanced" (sin cambios)
        PopupMenuButton<String>(
          onSelected: (String value) {
            if (value == 'biometric') {
              controller.biometricSearch();
            } else if (value == 'qr') {
              controller.qrCodeSearch();
            }
          },
          enabled: !controller.isLoading.value,
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'biometric',
              child: Row(
                children: [
                  Icon(
                    Icons.fingerprint,
                    size: 18,
                    color: AppTheme.getTextPrimary(context),
                  ),
                  const SizedBox(width: 8),
                  Text('Búsqueda biométrica'),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'qr',
              child: Row(
                children: [
                  Icon(
                    Icons.qr_code_scanner,
                    size: 18,
                    color: AppTheme.getTextPrimary(context),
                  ),
                  const SizedBox(width: 8),
                  Text('Escanear código QR'),
                ],
              ),
            ),
          ],
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.primaryColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome, // Icono de IA
                  size: 16,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 6),
                Text(
                  'Advanced',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 16,
                  color: AppTheme.primaryColor,
                ),
              ],
            ),
          ),
        ),
      ],
    ));
  }
}