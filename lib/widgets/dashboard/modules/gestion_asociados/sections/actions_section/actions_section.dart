import 'package:flutter/material.dart';
import '../../../../../../utils/app_theme.dart';
import '../../../../../../controllers/asociados_controller.dart';
import 'components/data_management_actions.dart';
import 'components/tools_actions.dart';
import 'components/advanced_options_actions.dart';
import 'components/danger_zone_actions.dart';

class ActionsSection extends StatefulWidget {
  final Map<String, dynamic> asociado;
  final AsociadosController controller;

  const ActionsSection({
    super.key,
    required this.asociado,
    required this.controller,
  });

  @override
  State<ActionsSection> createState() => _ActionsSectionState();
}

class _ActionsSectionState extends State<ActionsSection> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
          _buildHeader(context),
          
          Expanded(
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Gestión de Datos
                    DataManagementActions(
                      onEdit: widget.controller.editAsociado,
                      onAddCarga: widget.controller.addCarga,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Herramientas - SIN onGenerateQR
                    ToolsActions(
                      onViewHistory: widget.controller.viewHistory,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Opciones Avanzadas
                    const AdvancedOptionsActions(),
                    
                    const SizedBox(height: 20),
                    
                    // Zona de Peligro
                    DangerZoneActions(
                      asociado: widget.asociado,
                      onDelete: widget.controller.deleteAsociado,
                    ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.settings,
            color: AppTheme.primaryColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            'Acciones',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}