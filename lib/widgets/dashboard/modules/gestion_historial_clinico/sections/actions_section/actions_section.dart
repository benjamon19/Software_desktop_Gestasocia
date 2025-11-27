import 'package:flutter/material.dart';
import '../../../../../../utils/app_theme.dart';
import '../../../../../../controllers/historial_clinico_controller.dart';
import '../../../../../../models/historial_clinico.dart';
import 'components/quick_actions.dart';

class ActionsSection extends StatefulWidget {
  final Map<String, dynamic> historial;
  final HistorialClinicoController controller;

  const ActionsSection({
    super.key,
    required this.historial,
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

  HistorialClinico _reconstructHistorial(Map<String, dynamic> map) {
    return HistorialClinico(
      id: map['id'] as String?,
      pacienteId: map['pacienteId'] as String,
      pacienteTipo: map['pacienteTipo'] as String,
      tipoConsulta: map['tipoConsulta']?.toString().toLowerCase() ?? 'consulta',
      odontologo: map['odontologo'] as String,
      fecha: _parseDate(map['fecha']) ?? DateTime.now(),
      hora: map['hora'] as String,
      motivoPrincipal: map['motivoPrincipal'] as String,
      diagnostico: map['diagnostico'] as String?,
      tratamientoRealizado: map['tratamientoRealizado'] as String?,
      dienteTratado: map['dienteTratado'] as String?,
      observacionesOdontologo: map['observacionesOdontologo'] as String?,
      alergias: map['alergias'] as String?,
      medicamentosActuales: map['medicamentosActuales'] as String?,
      proximaCita: _parseDate(map['proximaCita']),
      estado: map['estado']?.toString().toLowerCase() ?? 'pendiente',
      costoTratamiento: map['costoTratamiento'] is num ? (map['costoTratamiento'] as num).toDouble() : null,
      imagenUrl: map['imagenUrl'] as String?,
      imagenLocalPath: null,
      fechaCreacion: _parseDate(map['fechaCreacion']) ?? DateTime.now(),
      fechaActualizacion: _parseDate(map['fechaActualizacion']),
    );
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final historialObj = _reconstructHistorial(widget.historial);

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
                    QuickActions(
                      historial: historialObj,
                      controller: widget.controller,
                      onDeleteHistorial: () {
                        widget.controller.deleteHistorialCompleto(historialObj.id!);
                      },
                    ),
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