import 'package:flutter/material.dart';
import '../../../../../../utils/app_theme.dart';
import '../../../../../../controllers/cargas_familiares_controller.dart';
import 'components/data_management_actions.dart';
import 'components/tools_actions.dart';
import 'components/advanced_options_actions.dart';
import 'components/danger_zone_actions.dart';

class ActionsSection extends StatefulWidget {
  final Map<String, dynamic> carga;
  final CargasFamiliaresController controller;

  const ActionsSection({
    super.key,
    required this.carga,
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
                    // Gestión de Carga
                    DataManagementActions(
                      onEdit: widget.controller.editCarga,
                      onTransfer: widget.controller.transferCarga,
                    ),
                    
                    const SizedBox(height: 22),
                    
                    // Herramientas
                    ToolsActions(
                      onGenerateBarcode: widget.controller.generateCarnet,
                      onViewHistory: widget.controller.viewHistory,
                    ),
                    
                    const SizedBox(height: 22),
                    
                    // Opciones Avanzadas
                    const AdvancedOptionsActions(),
                    
                    const SizedBox(height: 22),
                    
                    // Zona de Peligro
                    DangerZoneActions(
                      carga: widget.carga,
                      onDelete: widget.controller.deleteCarga,
                    ),
                    
                    const SizedBox(height: 22),
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
        color: const Color(0xFF10B981).withValues(alpha: 0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.settings,
            color: Color(0xFF10B981),
            size: 24,
          ),
          const SizedBox(width: 12),
          const Text(
            'Acciones',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );
  }
}