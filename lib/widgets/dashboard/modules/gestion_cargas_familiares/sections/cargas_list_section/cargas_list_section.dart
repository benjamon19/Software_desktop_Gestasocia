import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../utils/app_theme.dart';
import '../../../../../../controllers/cargas_familiares_controller.dart';

class CargasListSection extends StatelessWidget {
  final List<Map<String, dynamic>> cargas;
  final Function(Map<String, dynamic>) onCargaSelected;
  final CargasFamiliaresController controller;

  const CargasListSection({
    super.key,
    required this.cargas,
    required this.onCargaSelected,
    required this.controller,
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
            Icons.family_restroom,
            color: AppTheme.primaryColor,
            size: isVerySmall ? 18 : (isSmallScreen ? 20 : 24),
          ),
          SizedBox(width: isVerySmall ? 8 : 12),
          Expanded(
            child: Text(
              isVerySmall ? 'Cargas' : 'Lista de Cargas Familiares',
              style: TextStyle(
                fontSize: isVerySmall ? 14 : (isSmallScreen ? 16 : 20),
                fontWeight: FontWeight.bold,
                color: AppTheme.getTextPrimary(context),
              ),
            ),
          ),
          if (!isVerySmall) ...[
            _buildRefreshButton(isSmallScreen),
            SizedBox(width: isSmallScreen ? 6 : 8),
          ],
          _buildCounterBadge(isSmallScreen, isVerySmall),
        ],
      ),
    );
  }

  Widget _buildRefreshButton(bool isSmallScreen) {
    return IconButton(
      onPressed: () => controller.refreshCargas(),
      icon: Icon(
        Icons.refresh,
        color: AppTheme.primaryColor,
        size: isSmallScreen ? 18 : 20,
      ),
      tooltip: 'Recargar lista',
      padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
    );
  }

  Widget _buildCounterBadge(bool isSmallScreen, bool isVerySmall) {
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
        final total = controller.filteredCargas.length;
        final totalGeneral = controller.allCargas.length;

        String texto;
        if (isVerySmall) {
          texto = total.toString();
        } else if (isSmallScreen) {
          texto = controller.searchText.value.isEmpty
              ? '$total'
              : '$total/$totalGeneral';
        } else {
          texto = controller.searchText.value.isEmpty
              ? '$total cargas'
              : '$total de $totalGeneral cargas';
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

  Widget _buildList(BuildContext context, bool isSmallScreen, bool isVerySmall) {
    if (cargas.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.separated(
      padding: EdgeInsets.all(isVerySmall ? 8 : (isSmallScreen ? 12 : 16)),
      itemCount: cargas.length,
      separatorBuilder: (context, index) => SizedBox(height: isVerySmall ? 4 : 6),
      itemBuilder: (context, index) {
        final carga = cargas[index];
        return _buildCargaListItem(context, carga, isSmallScreen, isVerySmall);
      },
    );
  }

  Widget _buildCargaListItem(
    BuildContext context,
    Map<String, dynamic> carga,
    bool isSmallScreen,
    bool isVerySmall,
  ) {
    final hovered = false.obs;

    return ObxValue<RxBool>(
      (hover) => InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onCargaSelected(carga),
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
              _buildAvatar(context, carga, isSmallScreen, isVerySmall),
              SizedBox(width: isVerySmall ? 8 : (isSmallScreen ? 10 : 16)),
              _buildCargaInfo(context, carga, isSmallScreen, isVerySmall),
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

  Widget _buildAvatar(
    BuildContext context,
    Map<String, dynamic> carga,
    bool isSmallScreen,
    bool isVerySmall,
  ) {
    final avatarSize = isVerySmall ? 28.0 : (isSmallScreen ? 36.0 : 44.0);
    final iconSize = isVerySmall ? 16.0 : (isSmallScreen ? 20.0 : 24.0);
    final indicatorSize = isVerySmall ? 8.0 : (isSmallScreen ? 10.0 : 12.0);

    final cargaModel = controller.cargasFamiliares.firstWhereOrNull(
      (c) => c.id == carga['id'],
    );
    final bool estaActivo = cargaModel?.estaActivo ?? true;

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
            _getParentescoIcon(carga['parentesco']),
            size: iconSize,
            color: Colors.grey.shade600,
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: indicatorSize,
            height: indicatorSize,
            decoration: BoxDecoration(
              color: estaActivo
                  ? const Color(0xFF10B981)
                  : const Color(0xFFEF4444),
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

  Widget _buildCargaInfo(
    BuildContext context,
    Map<String, dynamic> carga,
    bool isSmallScreen,
    bool isVerySmall,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            carga['nombreCompleto'] ?? 'Sin nombre',
            style: TextStyle(
              fontSize: isVerySmall ? 12 : (isSmallScreen ? 13 : 16),
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextPrimary(context),
            ),
            overflow: TextOverflow.ellipsis,
          ),
          if (!isVerySmall) const SizedBox(height: 2),
          if (isVerySmall)
            Text(
              carga['rutFormateado'] ?? '',
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
                  carga['rutFormateado'] ?? '',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.getTextSecondary(context),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    carga['parentesco'] ?? '',
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
                  carga['rutFormateado'] ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.getTextSecondary(context),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.favorite_outline, size: 12, color: AppTheme.getTextSecondary(context)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${carga['parentesco']} • ${carga['edad']} años',
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
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isVerySmall = screenWidth < 400;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.family_restroom_outlined,
            size: isVerySmall ? 40 : 48,
            color: AppTheme.getTextSecondary(context).withValues(alpha: 0.3),
          ),
          SizedBox(height: isVerySmall ? 8 : 12),
          Text(
            isVerySmall ? 'Sin cargas' : 'No se encontraron cargas familiares',
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

  IconData _getParentescoIcon(String? parentesco) {
    if (parentesco == null) return Icons.person;

    switch (parentesco.toLowerCase()) {
      case 'hijo':
        return Icons.boy;
      case 'hija':
        return Icons.girl;
      case 'cónyuge':
        return Icons.favorite;
      case 'padre':
      case 'madre':
        return Icons.elderly;
      default:
        return Icons.person;
    }
  }
}