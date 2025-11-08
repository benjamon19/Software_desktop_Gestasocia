import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../../../utils/app_theme.dart';

class CargaFamiliarSearchField extends StatefulWidget {
  final Function(String) onSearch;
  final Function(String)? onChanged;
  final bool isLoading;

  const CargaFamiliarSearchField({
    super.key,
    required this.onSearch,
    this.onChanged,
    this.isLoading = false,
  });

  @override
  State<CargaFamiliarSearchField> createState() => _CargaFamiliarSearchFieldState();
}

class _CargaFamiliarSearchFieldState extends State<CargaFamiliarSearchField> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // Método público para limpiar el campo
  void clearField() {
    _searchController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: (node, event) {
        // Manejar tecla ESC para limpiar el campo
        if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
          if (_searchController.text.isNotEmpty) {
            _searchController.clear();
            setState(() {});
            if (widget.onChanged != null) {
              widget.onChanged!('');
            }
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: TextFormField(
        controller: _searchController,
        focusNode: _focusNode,
        enabled: !widget.isLoading,
        decoration: InputDecoration(
          labelText: 'SAP, RUT o Código de Barras',
          hintText: '12345 (SAP) o 12345678-9 (RUT)',
          prefixIcon: Icon(
            Icons.family_restroom,
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
                    if (widget.onChanged != null) {
                      widget.onChanged!('');
                    }
                  },
                  icon: Icon(
                    Icons.clear,
                    color: AppTheme.getTextSecondary(context),
                    size: 18,
                  ),
                  tooltip: 'Limpiar',
                ),
              // Botón de búsqueda exacta
              IconButton(
                onPressed: widget.isLoading || _searchController.text.trim().isEmpty 
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
            borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppTheme.getBorderLight(context)),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.red, width: 1),
          ),
          labelStyle: TextStyle(color: AppTheme.getTextSecondary(context)),
          hintStyle: TextStyle(
            color: AppTheme.getTextSecondary(context).withValues(alpha: 0.7),
          ),
        ),
        style: TextStyle(color: AppTheme.getTextPrimary(context)),
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.search,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9kK\-]')),
          LengthLimitingTextInputFormatter(12),
          _DelayedRutFormatter(),
        ],
        onFieldSubmitted: (_) => _handleSearch(),
        onChanged: (value) {
          setState(() {});
          // Llamar búsqueda en tiempo real
          if (widget.onChanged != null) {
            widget.onChanged!(value.trim());
          }
        },
        validator: _validateInput,
      ),
    );
  }

  void _handleSearch() {
    final input = _searchController.text.trim();
    if (input.isNotEmpty && _validateInput(input) == null) {
      _focusNode.unfocus();
      widget.onSearch(input);
    }
  }

  String? _validateInput(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    
    // Si es SAP (5 dígitos), es válido
    if (_isSAP(value)) {
      return null;
    }
    
    // Si no es SAP, validar como RUT
    if (!_isValidRutFormat(value)) {
      return 'Formato inválido. Use SAP (5 dígitos) o RUT (12345678-9)';
    }
    
    return null;
  }

  bool _isSAP(String input) {
    // SAP es exactamente 5 dígitos
    return RegExp(r'^[0-9]{5}$').hasMatch(input);
  }

  bool _isValidRutFormat(String rut) {
    // Acepta RUT con guión o sin guión (para cuando está escribiendo)
    final rutWithDash = RegExp(r'^\d{7,8}-[0-9kK]$');
    final rutWithoutDash = RegExp(r'^\d{8,9}$');
    return rutWithDash.hasMatch(rut) || rutWithoutDash.hasMatch(rut);
  }
}

// Formatter que SOLO formatea cuando ya escribiste 8-9 dígitos
class _DelayedRutFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text.replaceAll('-', '');
    
    // Si tiene menos de 8 caracteres, NO formatear
    if (text.length < 8) {
      return newValue;
    }
    
    // Si tiene 8 o 9 caracteres (RUT completo), formatear con guión
    if (text.length >= 8 && text.length <= 9) {
      String body = text.substring(0, text.length - 1);
      String dv = text.substring(text.length - 1);
      String formatted = '$body-$dv';
      
      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
    
    return newValue;
  }
}