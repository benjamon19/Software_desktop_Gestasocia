import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../utils/app_theme.dart';
import '../../../../../../controllers/cargas_familiares_controller.dart';
import '../search_section/components/carga_familiar_search_field.dart';

class SearchSection extends StatefulWidget {
  final CargasFamiliaresController controller;

  const SearchSection({
    super.key,
    required this.controller,
  });

  @override
  State<SearchSection> createState() => _SearchSectionState();
}

class _SearchSectionState extends State<SearchSection> {
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
          child: CargaFamiliarSearchField(
            key: widget.controller.searchFieldKey,
            onSearch: widget.controller.searchCargas,
            onChanged: (query) => widget.controller.onSearchQueryChanged(query),
            isLoading: widget.controller.isLoading.value,
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Botón de código de barras
        InkWell(
          onTap: widget.controller.isLoading.value ? null : () {
            widget.controller.qrCodeSearch();
          },
          borderRadius: BorderRadius.circular(8),
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
                  Icons.qr_code_scanner,
                  size: 16,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 6),
                Text(
                  'Código de barras',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ));
  }
}