import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../utils/app_theme.dart';
import '../../../../../../controllers/cargas_familiares_controller.dart' as cargas_controller;
import '../../../../../../controllers/asociados_controller.dart';

class CargasListSection extends StatelessWidget {
  final List<Map<String, dynamic>> cargas;
  final Function(Map<String, dynamic>) onCargaSelected;
  final cargas_controller.CargasFamiliaresController controller;

  const CargasListSection({
    super.key,
    required this.cargas,
    required this.onCargaSelected,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    // Ordenar la lista de cargas alfabéticamente por el nombre completo
    final sortedCargas = [...cargas];
    sortedCargas.sort((a, b) {
      final nombreA = '${a['nombre']} ${a['apellido']}'.toLowerCase();
      final nombreB = '${b['nombre']} ${b['apellido']}'.toLowerCase();
      return nombreA.compareTo(nombreB);
    });

    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 600;
    final bool isVerySmall = screenWidth < 400;

    return Column(
      children: [
        // Header de la sección (visible siempre)
        _buildHeader(context, isSmallScreen, isVerySmall),
        const SizedBox(height: 12),
        // Contenido principal (lista o estado vacío)
        Expanded(
          child: _buildListContent(context, isSmallScreen, isVerySmall, sortedCargas),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, bool isSmallScreen, bool isVerySmall) {
    return Container(
      padding: EdgeInsets.all(isVerySmall ? 8 : (isSmallScreen ? 10 : 12)),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildCounterBadge(context, isSmallScreen, isVerySmall, cargas.length),
          const Spacer(),
          _buildRefreshButton(controller, isSmallScreen, isVerySmall),
        ],
      ),
    );
  }

  Widget _buildListContent(BuildContext context, bool isSmallScreen, bool isVerySmall, List<Map<String, dynamic>> sortedCargas) {
    if (sortedCargas.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: AppTheme.getSurfaceColor(context),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withValues(alpha:0.3)
                  : Colors.grey.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.group_outlined, size: isVerySmall ? 24 : (isSmallScreen ? 32 : 48), color: Colors.grey),
              SizedBox(height: isVerySmall ? 6 : (isSmallScreen ? 8 : 16)),
              Text(
                'Sin resultados',
                style: TextStyle(fontSize: isVerySmall ? 12 : (isSmallScreen ? 14 : 16), color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withValues(alpha:0.3)
                : Colors.grey.withValues(alpha:0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Lista de cargas ultra compacta
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.all(isVerySmall ? 8 : (isSmallScreen ? 10 : 12)),
              itemCount: sortedCargas.length,
              separatorBuilder: (context, index) => SizedBox(height: isVerySmall ? 4 : 6),
              itemBuilder: (context, index) {
                final carga = sortedCargas[index];
                return _buildCargaListItem(context, carga, isSmallScreen, isVerySmall);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRefreshButton(cargas_controller.CargasFamiliaresController controller, bool isSmallScreen, bool isVerySmall) {
    return IconButton(
      onPressed: () => controller.refreshCargas(),
      icon: Icon(
        Icons.refresh,
        color: AppTheme.primaryColor,
        size: isVerySmall ? 14 : (isSmallScreen ? 16 : 18),
      ),
      tooltip: 'Recargar',
      padding: EdgeInsets.all(isVerySmall ? 4 : 8),
      constraints: BoxConstraints(
        minWidth: isVerySmall ? 24 : 32,
        minHeight: isVerySmall ? 24 : 32,
      ),
    );
  }

  Widget _buildCounterBadge(BuildContext context, bool isSmallScreen, bool isVerySmall, int count) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isVerySmall ? 6 : (isSmallScreen ? 8 : 10),
        vertical: isVerySmall ? 2 : (isSmallScreen ? 3 : 4)
      ),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(isVerySmall ? 8 : 12),
      ),
      child: Text(
        '$count${isVerySmall ? '' : (isSmallScreen ? '' : ' cargas')}',
        style: TextStyle(
          fontSize: isVerySmall ? 10 : (isSmallScreen ? 11 : 12),
          fontWeight: FontWeight.w600,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildCargaListItem(BuildContext context, Map<String, dynamic> carga, bool isSmallScreen, bool isVerySmall) {
    return _CargaItemWidget(
      carga: carga,
      onCargaSelected: onCargaSelected,
      isSmallScreen: isSmallScreen,
      isVerySmall: isVerySmall,
      controller: controller,
    );
  }
}

// Widget separado para manejar el hover sin GetX
class _CargaItemWidget extends StatefulWidget {
  final Map<String, dynamic> carga;
  final Function(Map<String, dynamic>) onCargaSelected;
  final bool isSmallScreen;
  final bool isVerySmall;
  final cargas_controller.CargasFamiliaresController controller;

  const _CargaItemWidget({
    required this.carga,
    required this.onCargaSelected,
    required this.isSmallScreen,
    required this.isVerySmall,
    required this.controller,
  });

  @override
  State<_CargaItemWidget> createState() => _CargaItemWidgetState();
}

class _CargaItemWidgetState extends State<_CargaItemWidget> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => widget.onCargaSelected(widget.carga),
      onHover: (value) => setState(() => isHovered = value),
      child: Container(
        padding: EdgeInsets.all(widget.isVerySmall ? 6 : (widget.isSmallScreen ? 8 : 10)),
        decoration: BoxDecoration(
          color: isHovered
              ? AppTheme.primaryColor.withAlpha(10)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            _buildAvatar(context, widget.carga, widget.isSmallScreen, widget.isVerySmall),
            SizedBox(width: widget.isVerySmall ? 6 : (widget.isSmallScreen ? 8 : 12)),
            _buildCargaInfo(context, widget.carga, widget.isSmallScreen, widget.isVerySmall),
            if (!widget.isVerySmall) ...[
              SizedBox(width: widget.isSmallScreen ? 4 : 6),
              Icon(
                Icons.chevron_right,
                size: widget.isSmallScreen ? 12 : 14,
                color: AppTheme.getTextSecondary(context),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, Map<String, dynamic> carga, bool isSmallScreen, bool isVerySmall) {
    final avatarSize = isVerySmall ? 24.0 : (isSmallScreen ? 32.0 : 40.0);
    final iconSize = isVerySmall ? 14.0 : (isSmallScreen ? 18.0 : 22.0);
    final indicatorSize = isVerySmall ? 6.0 : (isSmallScreen ? 8.0 : 10.0);

    return Stack(
      children: [
        Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            color: _getParentescoColor(carga['parentesco'] ?? '').withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: _getParentescoColor(carga['parentesco'] ?? '').withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Icon(
            _getParentescoIcon(carga['parentesco'] ?? ''),
            size: iconSize,
            color: _getParentescoColor(carga['parentesco'] ?? '')
          ),
        ),
        // Indicador de estado
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: indicatorSize,
            height: indicatorSize,
            decoration: BoxDecoration(
              color: (carga['isActive'] == true) ? const Color(0xFF10B981) : const Color(0xFFEF4444),
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

  Widget _buildCargaInfo(BuildContext context, Map<String, dynamic> carga, bool isSmallScreen, bool isVerySmall) {
    // Obtener el asociadoId del mapa
    final String? asociadoId = carga['asociadoId']?.toString();
    final String asociadoNombre = _getAsociadoNombre(asociadoId);
    
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nombre de la carga familiar
          Text(
            isVerySmall
                ? '${carga['nombre']?.toString().split(' ')[0] ?? 'Sin'} ${carga['apellido']?.toString().split(' ')[0] ?? 'nombre'}'
                : '${carga['nombre'] ?? 'Sin nombre'} ${carga['apellido'] ?? ''}',
            style: TextStyle(
              fontSize: isVerySmall ? 11 : (isSmallScreen ? 12 : 13),
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextPrimary(context),
            ),
            overflow: TextOverflow.ellipsis,
          ),
          if (!isVerySmall) SizedBox(height: 1),
          
          // Información del asociado titular
          Text(
            'Titular: $asociadoNombre',
            style: TextStyle(
              fontSize: isVerySmall ? 8 : (isSmallScreen ? 9 : 10),
              color: AppTheme.getTextSecondary(context),
              fontStyle: FontStyle.italic,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          
          if (isVerySmall)
            // Ultra compacto: solo parentesco
            Text(
              carga['parentesco'] ?? 'Sin parentesco',
              style: TextStyle(
                fontSize: 9,
                color: _getParentescoColor(carga['parentesco'] ?? ''),
              ),
              overflow: TextOverflow.ellipsis,
            )
          else if (isSmallScreen)
            // Compacto: parentesco y edad
            Text(
              '${carga['parentesco'] ?? 'Sin parentesco'} • ${_calcularEdad(carga['fechaNacimiento'])}a',
              style: TextStyle(
                fontSize: 10,
                color: _getParentescoColor(carga['parentesco'] ?? ''),
              ),
              overflow: TextOverflow.ellipsis,
            )
          else
            // Normal: información completa pero compacta
            Row(
              children: [
                Icon(_getParentescoIcon(carga['parentesco'] ?? ''),
                    size: 12, color: _getParentescoColor(carga['parentesco'] ?? '')),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${carga['parentesco'] ?? 'Sin parentesco'} • ${_calcularEdad(carga['fechaNacimiento'])} años',
                    style: TextStyle(
                      fontSize: 11,
                      color: _getParentescoColor(carga['parentesco'] ?? ''),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  String _getAsociadoNombre(String? asociadoId) {
    if (asociadoId == null || asociadoId.isEmpty) return 'Sin titular';
    
    try {
      // Obtener el AsociadosController
      final AsociadosController asociadosController = Get.find<AsociadosController>();
      
      // Usar el método getAsociadoById
      final asociado = asociadosController.getAsociadoById(asociadoId);
      
      if (asociado != null) {
        return asociado.nombreCompleto;
      }
      
    } catch (e) {
      // Si hay error al acceder al controller
    }
    
    // Fallback: mostrar ID truncado si no se encuentra el asociado
    return 'Titular: ${asociadoId.substring(0, 8)}...';
  }

  int _calcularEdad(dynamic fechaNacimiento) {
    if (fechaNacimiento == null) return 0;
    
    DateTime fecha;
    if (fechaNacimiento is DateTime) {
      fecha = fechaNacimiento;
    } else if (fechaNacimiento is String) {
      try {
        fecha = DateTime.parse(fechaNacimiento);
      } catch (e) {
        return 0;
      }
    } else {
      return 0;
    }
    
    final now = DateTime.now();
    int age = now.year - fecha.year;
    if (now.month < fecha.month || (now.month == fecha.month && now.day < fecha.day)) {
      age--;
    }
    return age;
  }

  IconData _getParentescoIcon(String parentesco) {
    switch (parentesco.toLowerCase()) {
      case 'hijo/a':
        return Icons.child_care;
      case 'cónyuge':
        return Icons.favorite;
      case 'padre':
      case 'madre':
        return Icons.elderly;
      case 'hermano/a':
        return Icons.people;
      case 'abuelo/a':
        return Icons.family_restroom;
      case 'nieto/a':
        return Icons.face;
      case 'tío/a':
        return Icons.diversity_1;
      case 'sobrino/a':
        return Icons.supervised_user_circle;
      case 'otro':
        return Icons.person_pin;
      default:
        return Icons.person;
    }
  }

  Color _getParentescoColor(String parentesco) {
    switch (parentesco.toLowerCase()) {
      case 'hijo/a':
        return const Color(0xFF10B981); // Verde esmeralda
      case 'cónyuge':
        return const Color(0xFFEC4899); // Rosa fucsia
      case 'padre':
      case 'madre':
        return const Color(0xFF8B5CF6); // Púrpura intenso
      case 'hermano/a':
        return const Color(0xFFF59E0B); // Naranja
      case 'abuelo/a':
        return const Color(0xFF6366F1); // Azul índigo
      case 'nieto/a':
        return const Color(0xFFF97316); // Naranja oscuro
      case 'tío/a':
        return const Color(0xFFEF4444); // Rojo vibrante
      case 'sobrino/a':
        return const Color(0xFF06B6D4); // Cian
      case 'otro':
        return const Color(0xFF6B7280); // Gris
      default:
        return const Color(0xFF6B7280); // Gris por defecto
    }
  }
}