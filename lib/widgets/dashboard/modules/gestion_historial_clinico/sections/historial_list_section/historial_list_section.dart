import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../utils/app_theme.dart';
import '../../../../../../controllers/historial_clinico_controller.dart';

class HistorialListSection extends StatelessWidget {
  final List<Map<String, dynamic>> historiales;
  final Function(Map<String, dynamic>) onHistorialSelected;
  final Function(String) onFilterChanged;
  final Function(String) onStatusChanged;
  final Function(String) onOdontologoChanged;
  final String selectedFilter;
  final String selectedStatus;
  final String selectedOdontologo;

  const HistorialListSection({
    super.key,
    required this.historiales,
    required this.onHistorialSelected,
    required this.onFilterChanged,
    required this.onStatusChanged,
    required this.onOdontologoChanged,
    required this.selectedFilter,
    required this.selectedStatus,
    required this.selectedOdontologo,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 600;
    final bool isVerySmall = screenWidth < 400;
    
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
          _buildHeader(context, isSmallScreen, isVerySmall),
          Expanded(
            child: _buildList(context, isSmallScreen, isVerySmall),
          ),
        ],
      ),
    );
  }

  // Header con título, botón de refresco y contador
  Widget _buildHeader(BuildContext context, bool isSmallScreen, bool isVerySmall) {
    return Container(
      padding: EdgeInsets.all(isVerySmall ? 12 : (isSmallScreen ? 16 : 20)),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.medical_information_outlined, 
            color: AppTheme.primaryColor, 
            size: isVerySmall ? 18 : (isSmallScreen ? 20 : 24)
          ),
          SizedBox(width: isVerySmall ? 8 : 12),
          Expanded(
            child: Text(
              isVerySmall ? 'Historiales' : 'Lista de Historiales',
              style: TextStyle(
                fontSize: isVerySmall ? 14 : (isSmallScreen ? 16 : 20),
                fontWeight: FontWeight.bold,
                color: AppTheme.getTextPrimary(context),
              ),
            ),
          ),
          if (!isVerySmall) ...[
            _buildRefreshButton(context, isSmallScreen),
            SizedBox(width: isSmallScreen ? 6 : 8),
          ],
          _buildCounterBadge(context, isSmallScreen, isVerySmall),
        ],
      ),
    );
  }

  // Botón para recargar la lista de historiales
  Widget _buildRefreshButton(BuildContext context, bool isSmallScreen) {
    return IconButton(
      onPressed: () {
        final controller = Get.find<HistorialClinicoController>();
        controller.loadHistorialesFromFirebase();
      },
      icon: Icon(
        Icons.refresh,
        color: AppTheme.primaryColor,
        size: isSmallScreen ? 18 : 20,
      ),
      tooltip: 'Recargar lista',
      padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
    );
  }

  // Badge que muestra el contador de historiales
  Widget _buildCounterBadge(BuildContext context, bool isSmallScreen, bool isVerySmall) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isVerySmall ? 6 : (isSmallScreen ? 8 : 12),
        vertical: isVerySmall ? 3 : (isSmallScreen ? 4 : 6),
      ),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(isVerySmall ? 12 : 20),
      ),
      child: Obx(() {
        final controller = Get.find<HistorialClinicoController>();
        final total = historiales.length;
        final totalGeneral = controller.totalRegistros;
        final hayFiltros = controller.searchQuery.value.isNotEmpty ||
                           controller.selectedFilter.value != 'todos' ||
                           controller.selectedStatus.value != 'todos' ||
                           controller.selectedOdontologo.value != 'todos';

        String texto;
        if (isVerySmall) {
          texto = total.toString();
        } else if (isSmallScreen) {
          texto = hayFiltros ? '$total/$totalGeneral' : '$total';
        } else {
          texto = hayFiltros ? '$total/$totalGeneral' : '$total';
        }

        return Text(
          texto,
          style: TextStyle(
            fontSize: isVerySmall ? 10 : (isSmallScreen ? 11 : 14),
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        );
      }),
    );
  }

  // Lista de historiales o estado vacío
  Widget _buildList(BuildContext context, bool isSmallScreen, bool isVerySmall) {
    if (historiales.isEmpty) {
      return _buildEmptyState(context, isVerySmall);
    }

    return ListView.separated(
      key: ValueKey(historiales.length),
      padding: EdgeInsets.all(isVerySmall ? 8 : (isSmallScreen ? 12 : 16)),
      itemCount: historiales.length,
      separatorBuilder: (context, index) => SizedBox(height: isVerySmall ? 4 : 6),
      itemBuilder: (context, index) {
        if (index >= historiales.length) return const SizedBox.shrink();
        final historial = historiales[index];
        return _buildHistorialCard(context, historial, isSmallScreen, isVerySmall);
      },
    );
  }

  // Card individual de historial CON hover y onTap
  Widget _buildHistorialCard(
    BuildContext context,
    Map<String, dynamic> historial,
    bool isSmallScreen,
    bool isVerySmall,
  ) {
    final hovered = false.obs; // Estado de hover

    return ObxValue<RxBool>(
      (hover) => InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onHistorialSelected(historial),
        onHover: (value) => hover.value = value,
        child: Container(
          padding: EdgeInsets.all(isVerySmall ? 8 : (isSmallScreen ? 10 : 12)),
          decoration: BoxDecoration(
            color: hover.value
                ? AppTheme.primaryColor.withAlpha(10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              _buildAvatar(context, historial, isSmallScreen, isVerySmall),
              SizedBox(width: isVerySmall ? 8 : (isSmallScreen ? 10 : 16)),
              Expanded(
                child: _buildHistorialInfo(context, historial, isSmallScreen, isVerySmall),
              ),
              if (!isVerySmall) ...[
                SizedBox(width: isSmallScreen ? 4 : 8),
                Icon(
                  Icons.chevron_right,
                  size: isSmallScreen ? 14 : 16,
                  color: AppTheme.getTextSecondary(context),
                ),
              ],
            ],
          ),
        ),
      ),
      hovered,
    );
  }

  // Avatar circular con ícono de tipo de consulta e indicador de estado
  Widget _buildAvatar(
    BuildContext context,
    Map<String, dynamic> historial,
    bool isSmallScreen,
    bool isVerySmall,
  ) {
    final avatarSize = isVerySmall ? 28.0 : (isSmallScreen ? 36.0 : 44.0);
    final iconSize = isVerySmall ? 16.0 : (isSmallScreen ? 20.0 : 24.0);
    final indicatorSize = isVerySmall ? 8.0 : (isSmallScreen ? 10.0 : 12.0);

    return Stack(
      children: [
        Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.getBorderLight(context),
              width: 1,
            ),
          ),
          child: Icon(
            _getTipoConsultaIcon(historial['tipoConsulta']),
            size: iconSize,
            color: Colors.grey.shade600,
          ),
        ),
        // Indicador de estado en la esquina inferior derecha
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: indicatorSize,
            height: indicatorSize,
            decoration: BoxDecoration(
              color: _getEstadoColor(historial['estado']),
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).scaffoldBackgroundColor,
                width: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Información del historial: nombre del paciente, tipo y datos adicionales
  Widget _buildHistorialInfo(
    BuildContext context,
    Map<String, dynamic> historial,
    bool isSmallScreen,
    bool isVerySmall,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nombre del paciente con badges de tipo de paciente y tipo de consulta
        Row(
          children: [
            Expanded(
              child: Text(
                historial['pacienteNombre'] ?? 'Sin nombre',
                style: TextStyle(
                  fontSize: isVerySmall ? 12 : (isSmallScreen ? 13 : 16),
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getTextPrimary(context),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Badge del tipo de paciente (Asociado o Carga)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getPacienteTipoColor(historial['pacienteTipo']).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _getPacienteTipoLabel(historial['pacienteTipo']),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: _getPacienteTipoColor(historial['pacienteTipo']),
                ),
              ),
            ),
          ],
        ),
        
        if (!isVerySmall) const SizedBox(height: 2),
        
        // RUT, tipo de consulta, fecha y odontólogo
        if (isVerySmall)
          Text(
            historial['pacienteRut'] ?? '',
            style: TextStyle(
              fontSize: 10,
              color: AppTheme.getTextSecondary(context),
            ),
            overflow: TextOverflow.ellipsis,
          )
        else if (isSmallScreen)
          Row(
            children: [
              Icon(Icons.badge, size: 12, color: AppTheme.getTextSecondary(context)),
              const SizedBox(width: 4),
              Text(
                historial['pacienteRut'] ?? '',
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.getTextSecondary(context),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: _getTipoConsultaColor(historial['tipoConsulta']).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  _getTipoConsultaShort(historial['tipoConsulta']),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: _getTipoConsultaColor(historial['tipoConsulta']),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '• ${historial['fecha']}',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.getTextSecondary(context),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          )
        else
          Row(
            children: [
              Icon(Icons.badge, size: 12, color: AppTheme.getTextSecondary(context)),
              const SizedBox(width: 4),
              Text(
                historial['pacienteRut'] ?? '',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.getTextSecondary(context),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: _getTipoConsultaColor(historial['tipoConsulta']).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  _getTipoConsultaShort(historial['tipoConsulta']),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: _getTipoConsultaColor(historial['tipoConsulta']),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.event_outlined, size: 12, color: AppTheme.getTextSecondary(context)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${historial['fecha']} • ${historial['odontologo']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.getTextSecondary(context),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
      ],
    );
  }

  // Estado vacío
  Widget _buildEmptyState(BuildContext context, bool isVerySmall) {
    final controller = Get.find<HistorialClinicoController>();
    final hayBusqueda = controller.searchQuery.value.isNotEmpty;
    final hayFiltros = controller.selectedFilter.value != 'todos' ||
                       controller.selectedStatus.value != 'todos' ||
                       controller.selectedOdontologo.value != 'todos';
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hayBusqueda || hayFiltros 
                ? Icons.search_off_outlined
                : Icons.folder_open_outlined,
            size: isVerySmall ? 40 : 48,
            color: AppTheme.getTextSecondary(context).withValues(alpha: 0.3),
          ),
          SizedBox(height: isVerySmall ? 8 : 12),
          Text(
            hayBusqueda || hayFiltros
                ? (isVerySmall ? 'Sin resultados' : 'No se encontraron historiales')
                : (isVerySmall ? 'Sin historiales' : 'No hay historiales registrados'),
            style: TextStyle(
              fontSize: isVerySmall ? 12 : 14,
              color: AppTheme.getTextSecondary(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Helpers (mismos que tenías)
  IconData _getTipoConsultaIcon(String? tipo) {
    if (tipo == null) return Icons.medical_information_outlined;
    switch (tipo.toLowerCase()) {
      case 'consulta': return Icons.medical_information_outlined;
      case 'control':  return Icons.check_circle_outline;
      case 'urgencia':  return Icons.emergency;
      case 'tratamiento': return Icons.healing;
      default: return Icons.medical_services_outlined;
    }
  }

  Color _getTipoConsultaColor(String? tipo) {
    if (tipo == null) return const Color(0xFF3B82F6);
    switch (tipo.toLowerCase()) {
      case 'consulta':    return const Color(0xFF3B82F6);
      case 'control':     return const Color(0xFF10B981);
      case 'urgencia':    return const Color(0xFFEF4444);
      case 'tratamiento': return const Color(0xFF8B5CF6);
      default:            return const Color(0xFF6B7280);
    }
  }

  String _getTipoConsultaShort(String? tipo) {
    if (tipo == null) return 'Consulta';
    switch (tipo.toLowerCase()) {
      case 'consulta':    return 'Consulta';
      case 'control':     return 'Control';
      case 'urgencia':    return 'Urgencia';
      case 'tratamiento': return 'Trat.';
      default:            return tipo;
    }
  }

  Color _getEstadoColor(String? estado) {
    if (estado == null) return const Color(0xFFF59E0B);
    switch (estado.toLowerCase()) {
      case 'completado': return const Color(0xFF10B981);
      case 'pendiente':  return const Color(0xFFF59E0B);
      default:           return const Color(0xFF6B7280);
    }
  }

  String _getPacienteTipoLabel(String? tipo) {
    if (tipo == null) return 'Asociado';
    switch (tipo.toLowerCase()) {
      case 'asociado': return 'Asociado';
      case 'carga':    return 'Carga';
      default:         return tipo;
    }
  }

  Color _getPacienteTipoColor(String? tipo) {
    if (tipo == null) return const Color(0xFF3B82F6);
    switch (tipo.toLowerCase()) {
      case 'asociado': return const Color(0xFF3B82F6);
      case 'carga':    return const Color(0xFF10B981);
      default:         return const Color(0xFF6B7280);
    }
  }
}