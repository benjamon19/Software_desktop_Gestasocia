import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math'; 
import '../../../../../../../utils/app_theme.dart';
import '../../../../../../controllers/asociados_controller.dart';
import '../../../../../../../models/asociado.dart';

class AsociadosListSection extends StatelessWidget {
  final List<Asociado> asociados;
  final Function(Asociado) onAsociadoSelected;
  final AsociadosController controller;

  // Variables para paginación local
  final RxInt _currentPage = 0.obs;
  final int _itemsPerPage = 20;

  AsociadosListSection({
    super.key,
    required this.asociados,
    required this.onAsociadoSelected,
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
          // Footer de paginación
          _buildPaginationFooter(context, isSmallScreen),
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
            Icons.people,
            color: AppTheme.primaryColor,
            size: isVerySmall ? 18 : (isSmallScreen ? 20 : 24),
          ),
          SizedBox(width: isVerySmall ? 8 : 12),
          Expanded(
            child: Text(
              isVerySmall ? 'Asociados' : 'Lista de Asociados',
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
      onPressed: () {
        controller.loadAsociados();
        _currentPage.value = 0;
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
        final total = controller.asociados.length;
        final totalGeneral = controller.totalAllAsociados;

        String texto;
        if (isVerySmall) {
          texto = total.toString();
        } else if (isSmallScreen) {
          texto = controller.searchQuery.value.isEmpty
              ? '$total'
              : '$total/$totalGeneral';
        } else {
          texto = controller.searchQuery.value.isEmpty
              ? '$total asociados'
              : '$total de $totalGeneral asociados';
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
    return Obx(() {
      final listaCompleta = asociados;

      if (listaCompleta.isEmpty) {
        return _buildEmptyState(context, isVerySmall);
      }

      // --- LOGICA PAGINACIÓN ---
      final totalItems = listaCompleta.length;
      final totalPages = (totalItems / _itemsPerPage).ceil();

      if (_currentPage.value >= totalPages && totalPages > 0) {
        _currentPage.value = 0;
      }

      final startIndex = _currentPage.value * _itemsPerPage;
      final endIndex = min(startIndex + _itemsPerPage, totalItems);

      if (startIndex > totalItems) {
        return _buildEmptyState(context, isVerySmall);
      }

      final listaPaginada = listaCompleta.sublist(startIndex, endIndex);
      // -------------------------

      return ListView.separated(
        key: ValueKey('list_${_currentPage.value}_${listaCompleta.length}'), 
        padding: EdgeInsets.all(isVerySmall ? 8 : (isSmallScreen ? 12 : 16)),
        itemCount: listaPaginada.length,
        separatorBuilder: (context, index) => SizedBox(height: isVerySmall ? 4 : 6),
        itemBuilder: (context, index) {
          final asociado = listaPaginada[index];
          return _buildAsociadoListItem(context, asociado, isSmallScreen, isVerySmall);
        },
      );
    });
  }

  // === FOOTER DE PAGINACIÓN ARREGLADO ===
  Widget _buildPaginationFooter(BuildContext context, bool isSmallScreen) {
    return Obx(() {
      final totalItems = asociados.length;
      if (totalItems <= _itemsPerPage) return const SizedBox.shrink();

      final totalPages = (totalItems / _itemsPerPage).ceil();
      final currentPageIndex = _currentPage.value;

      final startItem = (currentPageIndex * _itemsPerPage) + 1;
      final endItem = min((currentPageIndex + 1) * _itemsPerPage, totalItems);

      return Container(
        width: double.infinity, 
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppTheme.getBorderLight(context).withValues(alpha: 0.5),
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            
            Expanded(
              child: isSmallScreen 
                  ? const SizedBox.shrink()
                  : Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Mostrando $startItem-$endItem de $totalItems',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.getTextSecondary(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: currentPageIndex > 0
                      ? () => _currentPage.value--
                      : null,
                  icon: const Icon(Icons.chevron_left),
                  color: AppTheme.getTextPrimary(context),
                  disabledColor: Colors.grey.withValues(alpha: 0.3),
                  tooltip: 'Anterior',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '${currentPageIndex + 1} / $totalPages',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getTextPrimary(context),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: currentPageIndex < totalPages - 1
                      ? () => _currentPage.value++
                      : null,
                  icon: const Icon(Icons.chevron_right),
                  color: AppTheme.getTextPrimary(context),
                  disabledColor: Colors.grey.withValues(alpha: 0.3),
                  tooltip: 'Siguiente',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),

            Expanded(
              child: const SizedBox.shrink(),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildEmptyState(BuildContext context, bool isVerySmall) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: isVerySmall ? 40 : 48,
            color: AppTheme.getTextSecondary(context).withValues(alpha: 0.3),
          ),
          SizedBox(height: isVerySmall ? 8 : 12),
          Text(
            isVerySmall ? 'Sin asociados' : 'No se encontraron asociados',
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

  Widget _buildAsociadoListItem(
    BuildContext context,
    Asociado asociado,
    bool isSmallScreen,
    bool isVerySmall,
  ) {
    final hovered = false.obs;

    return ObxValue<RxBool>(
      (hover) => InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onAsociadoSelected(asociado),
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
              _buildAvatar(context, asociado, isSmallScreen, isVerySmall),
              SizedBox(width: isVerySmall ? 8 : (isSmallScreen ? 10 : 16)),
              _buildAsociadoInfo(context, asociado, isSmallScreen, isVerySmall),
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

  Widget _buildAvatar(BuildContext context, Asociado asociado, bool isSmallScreen, bool isVerySmall) {
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
          child: Icon(Icons.person, size: iconSize, color: Colors.grey.shade600),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: indicatorSize,
            height: indicatorSize,
            decoration: BoxDecoration(
              color: asociado.estaActivo
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

  Widget _buildAsociadoInfo(BuildContext context, Asociado asociado, bool isSmallScreen, bool isVerySmall) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            asociado.nombreCompleto,
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
              _formatearRut(asociado.rut),
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
                  _formatearRut(asociado.rut),
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.getTextSecondary(context),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    asociado.email,
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
                  _formatearRut(asociado.rut),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.getTextSecondary(context),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.email, size: 12, color: AppTheme.getTextSecondary(context)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    asociado.email,
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

  String _formatearRut(String rutRaw) {
    final clean = rutRaw.replaceAll(RegExp(r'[^0-9kK]'), '').toUpperCase();
    if (clean.isEmpty) return '';
    String cuerpo = clean.substring(0, clean.length - 1);
    String dv = clean.substring(clean.length - 1);
    cuerpo = cuerpo.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return '$cuerpo-$dv';
  }
}