import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSectionHeader(context),
        const SizedBox(height: 12),
        _buildSearchControls(context),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Text(
      'Buscador',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppTheme.getTextPrimary(context),
      ),
    );
  }

  Widget _buildSearchControls(BuildContext context) {
    return Column(
      children: [
        // Primera fila: Campo de búsqueda principal
        Row(
          children: [
            // Campo de búsqueda
            Expanded(
              child: Focus(
                onKeyEvent: (node, event) {
                  // Manejar tecla ESC para limpiar el campo
                  if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
                    if (_searchController.text.isNotEmpty) {
                      _searchController.clear();
                      widget.controller.clearSearch();
                      setState(() {});
                      return KeyEventResult.handled;
                    }
                  }
                  return KeyEventResult.ignored;
                },
                child: TextFormField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    labelText: 'SAP o RUT del Asociado o Carga',
                    hintText: '12345 (SAP) o 12345678-9 (RUT)',
                    prefixIcon: Icon(
                      Icons.medical_information,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Botón para limpiar campo
                        if (_searchController.text.trim().isNotEmpty)
                          IconButton(
                            onPressed: () {
                              _searchController.clear();
                              widget.controller.clearSearch();
                              setState(() {});
                            },
                            icon: Icon(
                              Icons.clear,
                              color: AppTheme.getTextSecondary(context),
                              size: 18,
                            ),
                            tooltip: 'Limpiar (ESC)',
                          ),
                        // Botón de búsqueda
                        IconButton(
                          onPressed: _searchController.text.trim().isEmpty 
                              ? null 
                              : () => _focusNode.unfocus(),
                          icon: Icon(
                            Icons.search,
                            color: _searchController.text.trim().isEmpty 
                                ? AppTheme.getTextSecondary(context)
                                : AppTheme.primaryColor,
                            size: 20,
                          ),
                          tooltip: 'Buscar',
                        ),
                      ],
                    ),
                    filled: true,
                    fillColor: AppTheme.getInputBackground(context),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppTheme.getBorderLight(context)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppTheme.primaryColor,
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppTheme.getBorderLight(context)),
                    ),
                    labelStyle: TextStyle(color: AppTheme.getTextSecondary(context)),
                    hintStyle: TextStyle(
                      color: AppTheme.getTextSecondary(context).withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                  style: TextStyle(
                    color: AppTheme.getTextPrimary(context),
                    fontSize: 14,
                  ),
                  textInputAction: TextInputAction.search,
                  onFieldSubmitted: (_) => _focusNode.unfocus(),
                  onChanged: (value) {
                    setState(() {});
                    widget.controller.searchHistorial(value);
                  },
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Segunda fila: Filtros compactos
        Row(
          children: [
            // Dropdown Tipo
            Expanded(
              child: Obx(() => _buildCompactDropdown(
                'Tipo',
                widget.controller.selectedFilter.value,
                [
                  {'value': 'todos', 'label': 'Todos', 'icon': Icons.all_inclusive},
                  {'value': 'consulta', 'label': 'Consulta', 'icon': Icons.medical_information_outlined},
                  {'value': 'control', 'label': 'Control', 'icon': Icons.check_circle_outline},
                  {'value': 'urgencia', 'label': 'Urgencia', 'icon': Icons.emergency},
                  {'value': 'tratamiento', 'label': 'Tratamiento', 'icon': Icons.healing},
                ],
                widget.controller.setFilter,
              )),
            ),
            
            const SizedBox(width: 8),
            
            // Dropdown Estado
            Expanded(
              child: Obx(() => _buildCompactDropdown(
                'Estado',
                widget.controller.selectedStatus.value,
                [
                  {'value': 'todos', 'label': 'Todos', 'icon': Icons.all_inclusive},
                  {'value': 'completado', 'label': 'Completado', 'icon': Icons.check_circle},
                  {'value': 'pendiente', 'label': 'Pendiente', 'icon': Icons.pending_actions},
                ],
                widget.controller.setStatus,
              )),
            ),
            
            const SizedBox(width: 8),
            
            // Dropdown Odontólogo
            Expanded(
              child: Obx(() => _buildCompactDropdown(
                'Odontólogo',
                widget.controller.selectedOdontologo.value,
                [
                  {'value': 'todos', 'label': 'Todos', 'icon': Icons.all_inclusive},
                  {'value': 'dr.lopez', 'label': 'Dr. López', 'icon': Icons.person},
                  {'value': 'dr.martinez', 'label': 'Dr. Martínez', 'icon': Icons.person},
                ],
                widget.controller.setOdontologo,
              )),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompactDropdown(
    String label,
    String value,
    List<Map<String, dynamic>> options,
    Function(String) onChanged,
  ) {
    final selectedOption = options.firstWhere(
      (opt) => opt['value'] == value,
      orElse: () => options.first,
    );

    return PopupMenuButton<String>(
      onSelected: (String newValue) {
        if (newValue != value) {
          onChanged(newValue);
        }
      },
      offset: const Offset(0, 40),
      itemBuilder: (BuildContext context) => options.map((option) {
        final isSelected = option['value'] == value;
        return PopupMenuItem<String>(
          value: option['value'],
          child: Row(
            children: [
              Icon(
                option['icon'] as IconData,
                size: 18,
                color: isSelected 
                    ? AppTheme.primaryColor 
                    : AppTheme.getTextSecondary(context),
              ),
              const SizedBox(width: 8),
              Text(
                option['label'],
                style: TextStyle(
                  color: isSelected 
                      ? AppTheme.primaryColor 
                      : AppTheme.getTextPrimary(context),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              if (isSelected) ...[
                const Spacer(),
                Icon(
                  Icons.check,
                  size: 16,
                  color: AppTheme.primaryColor,
                ),
              ],
            ],
          ),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: value == 'todos'
              ? AppTheme.getInputBackground(context)
              : AppTheme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: value == 'todos'
                ? AppTheme.getBorderLight(context)
                : AppTheme.primaryColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selectedOption['icon'] as IconData,
              size: 16,
              color: value == 'todos'
                  ? AppTheme.getTextSecondary(context)
                  : AppTheme.primaryColor,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                selectedOption['label'],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: value == 'todos'
                      ? AppTheme.getTextSecondary(context)
                      : AppTheme.primaryColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: value == 'todos'
                  ? AppTheme.getTextSecondary(context)
                  : AppTheme.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}