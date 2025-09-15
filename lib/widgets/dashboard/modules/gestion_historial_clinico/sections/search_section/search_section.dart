import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../utils/app_theme.dart';
import '../../../../../../controllers/historial_clinico_controller.dart';

class SearchSection extends StatefulWidget {
  final HistorialClinicoController controller;

  const SearchSection({super.key, required this.controller});

  @override
  State<SearchSection> createState() => _SearchSectionState();
}

class _SearchSectionState extends State<SearchSection> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.medical_information_outlined,
                color: AppTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Buscar Historial Clínico',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getTextPrimary(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Buscar por nombre del paciente o RUT',
                    hintText: 'María González, 12345678-9...',
                    prefixIcon: Icon(Icons.search, color: AppTheme.getTextSecondary(context)),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              widget.controller.clearSearch();
                              setState(() {});
                            },
                            icon: const Icon(Icons.clear),
                          )
                        : null,
                    filled: true,
                    fillColor: AppTheme.getInputBackground(context),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppTheme.getBorderLight(context)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppTheme.getBorderLight(context)),
                    ),
                    labelStyle: TextStyle(color: AppTheme.getTextSecondary(context)),
                    hintStyle: TextStyle(
                      color: AppTheme.getTextSecondary(context).withValues(alpha: 0.7),
                    ),
                  ),
                  style: TextStyle(color: AppTheme.getTextPrimary(context)),
                  onChanged: (value) {
                    setState(() {});
                    widget.controller.searchHistorial(value);
                  },
                ),
              ),
              const SizedBox(width: 12),
              // Dropdown de Tipo de Consulta con Obx
              Obx(() => _buildFilterDropdown(
                'Tipo', 
                widget.controller.selectedFilter.value, 
                ['todos', 'consulta', 'control', 'urgencia', 'tratamiento'], 
                widget.controller.setFilter
              )),
              const SizedBox(width: 12),
              // Dropdown de Estado con Obx
              Obx(() => _buildFilterDropdown(
                'Estado', 
                widget.controller.selectedStatus.value,
                ['todos', 'completado', 'pendiente'], 
                widget.controller.setStatus
              )),
              const SizedBox(width: 12),
              // Dropdown de Odontólogo con Obx
              Obx(() => _buildFilterDropdown(
                'Odontólogo', 
                widget.controller.selectedOdontologo.value,
                ['todos', 'dr.lopez', 'dr.martinez'], 
                widget.controller.setOdontologo
              )),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Busca por nombre del paciente, RUT o utiliza los filtros para encontrar historiales específicos',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.getTextSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(String label, String value, List<String> options, Function(String) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.getInputBackground(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.getBorderLight(context)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          icon: Icon(
            Icons.keyboard_arrow_down,
            size: 18,
            color: AppTheme.getTextSecondary(context),
          ),
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.getTextPrimary(context),
          ),
          dropdownColor: AppTheme.getSurfaceColor(context),
          items: options.map((option) => DropdownMenuItem(
            value: option,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$label: ${_getDisplayName(option)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.getTextPrimary(context),
                  ),
                ),
              ],
            ),
          )).toList(),
          onChanged: (newValue) {
            if (newValue != null && newValue != value) {
              onChanged(newValue);
            }
          },
        ),
      ),
    );
  }

  String _getDisplayName(String option) {
    switch (option) {
      case 'todos': return 'Todos';
      case 'consulta': return 'Consulta';
      case 'control': return 'Control';
      case 'urgencia': return 'Urgencia';
      case 'tratamiento': return 'Tratamiento';
      case 'completado': return 'Completado';
      case 'pendiente': return 'Pendiente';
      case 'dr.lopez': return 'Dr. López';
      case 'dr.martinez': return 'Dr. Martínez';
      default: return option[0].toUpperCase() + option.substring(1);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}