// lib/widgets/dashboard/modules/gestion_cargas_familiares/sections/search_section/search_section.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../../utils/app_theme.dart';
import '../../../../../../controllers/cargas_familiares_controller.dart' as cargas_controller;

class SearchSection extends StatefulWidget {
  final cargas_controller.CargasFamiliaresController controller;

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
    return _buildAdvancedSearchField(context);
  }

  Widget _buildAdvancedSearchField(BuildContext context) {
    return Focus(
      onKeyEvent: (node, event) {
        // Manejar tecla ESC para limpiar el campo
        if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
          if (_searchController.text.isNotEmpty) {
            _searchController.clear();
            setState(() {});
            widget.controller.clearSearch();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: TextFormField(
        controller: _searchController,
        focusNode: _focusNode,
        decoration: InputDecoration(
          labelText: 'Buscar por nombre, RUT o titular',
          hintText: 'María González, 12345678-9, Juan González...',
          prefixIcon: Icon(
            Icons.badge,
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
                    setState(() {});
                    widget.controller.clearSearch();
                  },
                  icon: Icon(
                    Icons.clear,
                    color: AppTheme.getTextSecondary(context),
                    size: 18,
                  ),
                  tooltip: 'Limpiar',
                ),
              // Botón de búsqueda exacta con lupa
              IconButton(
                onPressed: _searchController.text.trim().isEmpty 
                    ? null 
                    : _handleSearch,
                icon: Icon(
                  Icons.search,
                  color: _searchController.text.trim().isEmpty 
                      ? AppTheme.getTextSecondary(context)
                      : AppTheme.primaryColor,
                  size: 20,
                ),
                tooltip: 'Buscar exacto',
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
        style: TextStyle(color: AppTheme.getTextPrimary(context), fontSize: 14),
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.search,
        onFieldSubmitted: (_) => _handleSearch(),
        onChanged: (value) {
          setState(() {});
          widget.controller.searchCargas(value);
        },
      ),
    );
  }

  void _handleSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      _focusNode.unfocus();
      widget.controller.searchCargas(query);
    }
  }
}