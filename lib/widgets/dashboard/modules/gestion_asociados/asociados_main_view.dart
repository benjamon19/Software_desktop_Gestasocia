import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/app_theme.dart';
import '../../../../controllers/asociados_controller.dart';
import '../../../../models/asociado.dart';
import 'sections/search_section/search_section.dart';
import 'sections/profile_section/profile_section.dart';
import 'sections/actions_section/actions_section.dart';
import 'sections/empty_state_section/empty_state_section.dart';
import 'shared/widgets/loading_indicator.dart';

class AsociadosMainView extends StatelessWidget {
  const AsociadosMainView({super.key});

  @override
  Widget build(BuildContext context) {
    final AsociadosController controller = Get.find<AsociadosController>();

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Solo mostrar SearchSection cuando NO hay asociado seleccionado
            Obx(() {
              if (!controller.hasSelectedAsociado) {
                return Column(
                  children: [
                    SearchSection(controller: controller),
                    const SizedBox(height: 20),
                  ],
                );
              }
              return const SizedBox.shrink();
            }),
            
            Expanded(
              child: Obx(() => _buildMainContent(context, controller)),
            ),
          ],
        ),
      ),
      floatingActionButton: Obx(() => _buildFloatingActionButton(controller)),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildFloatingActionButton(AsociadosController controller) {
    if (!controller.hasSelectedAsociado) {
      return FloatingActionButton(
        onPressed: controller.newAsociado,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 8,
        child: const Icon(Icons.person_add, size: 24),
      );
    } else {
      return FloatingActionButton(
        mini: true,
        onPressed: () => _goBackToList(controller),
        backgroundColor: Colors.grey[600],
        foregroundColor: Colors.white,
        tooltip: 'Volver a la lista',
        child: const Icon(Icons.arrow_back, size: 20),
      );
    }
  }

  Widget _buildMainContent(BuildContext context, AsociadosController controller) {
    if (controller.isLoading.value) {
      return const LoadingIndicator();
    }

    if (controller.hasSelectedAsociado) {
      return _buildProfileView(controller);
    }

    if (controller.hasAsociados) {
      return _buildAsociadosList(context, controller);
    }

    return const EmptyStateSection();
  }

  Widget _buildProfileView(AsociadosController controller) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: ProfileSection(
            asociado: _asociadoToMap(controller.currentAsociado!),
            onEdit: controller.editAsociado,
            onBack: () => _goBackToList(controller),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          flex: 1,
          child: ActionsSection(
            asociado: _asociadoToMap(controller.currentAsociado!),
            controller: controller,
          ),
        ),
      ],
    );
  }

  Widget _buildAsociadosList(BuildContext context, AsociadosController controller) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 600;
    final bool isVerySmall = screenWidth < 400;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildListHeader(context, controller, isSmallScreen, isVerySmall),
        SizedBox(height: isVerySmall ? 12 : (isSmallScreen ? 16 : 20)),
        _buildListContent(context, controller, isSmallScreen, isVerySmall),
      ],
    );
  }

  Widget _buildListHeader(BuildContext context, AsociadosController controller, bool isSmallScreen, bool isVerySmall) {
    return Container(
      padding: EdgeInsets.all(isVerySmall ? 12 : (isSmallScreen ? 16 : 20)),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.people, color: AppTheme.primaryColor, size: isVerySmall ? 18 : (isSmallScreen ? 20 : 24)),
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
            _buildRefreshButton(controller, isSmallScreen),
            SizedBox(width: isSmallScreen ? 6 : 8),
          ],
          _buildCounterBadge(controller, isSmallScreen, isVerySmall),
        ],
      ),
    );
  }

  Widget _buildRefreshButton(AsociadosController controller, bool isSmallScreen) {
    return Obx(() => IconButton(
      onPressed: controller.isLoading.value
          ? null
          : () => controller.loadAsociados(),
      icon: controller.isLoading.value
          ? SizedBox(
              width: isSmallScreen ? 16 : 20,
              height: isSmallScreen ? 16 : 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              ),
            )
          : Icon(Icons.refresh, color: AppTheme.primaryColor, size: isSmallScreen ? 18 : 20),
      tooltip: 'Recargar lista',
      padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
    ));
  }

  Widget _buildCounterBadge(AsociadosController controller, bool isSmallScreen, bool isVerySmall) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isVerySmall ? 6 : (isSmallScreen ? 8 : 12), 
        vertical: isVerySmall ? 3 : (isSmallScreen ? 4 : 6)
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

  Widget _buildListContent(BuildContext context, AsociadosController controller, bool isSmallScreen, bool isVerySmall) {
    return Expanded(
      child: Container(
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
        child: Obx(() {
          final listaFiltrada = controller.asociados;
          return ListView.separated(
            key: ValueKey(listaFiltrada.length),
            padding: EdgeInsets.all(isVerySmall ? 8 : (isSmallScreen ? 12 : 16)),
            itemCount: listaFiltrada.length,
            separatorBuilder: (context, index) => SizedBox(height: isVerySmall ? 4 : 6),
            itemBuilder: (context, index) {
              if (index >= listaFiltrada.length) return const SizedBox.shrink();
              final asociado = listaFiltrada[index];
              return _buildAsociadoListItem(context, asociado, controller, isSmallScreen, isVerySmall);
            },
          );
        }),
      ),
    );
  }

  Widget _buildAsociadoListItem(
      BuildContext context, Asociado asociado, AsociadosController controller, bool isSmallScreen, bool isVerySmall) {
    final hovered = false.obs;

    return ObxValue<RxBool>(
      (hover) => InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _selectAsociado(controller, asociado),
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
              color: asociado.isActive
                  ? AppTheme.primaryColor
                  : Colors.grey.shade400,
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
          if (!isVerySmall) SizedBox(height: 2),
          if (isVerySmall)
            // Ultra compacto: solo RUT
            Text(
              _formatearRut(asociado.rut),
              style: TextStyle(
                fontSize: 10,
                color: AppTheme.getTextSecondary(context),
              ),
              overflow: TextOverflow.ellipsis,
            )
          else if (isSmallScreen)
            // Compacto: RUT y email truncado
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
            // Normal: información completa pero compacta
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

  void _selectAsociado(AsociadosController controller, Asociado asociado) {
    controller.selectedAsociado.value = asociado;
    controller.resetFilter();
    controller.clearSearchField();
  }

  void _goBackToList(AsociadosController controller) {
    controller.selectedAsociado.value = null;
    controller.resetFilter();
    controller.clearSearchField();
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

  Map<String, dynamic> _asociadoToMap(Asociado asociado) {
    return {
      'rut': asociado.rut,
      'nombre': asociado.nombre,
      'apellido': asociado.apellido,
      'email': asociado.email,
      'telefono': asociado.telefono,
      'fechaNacimiento': asociado.fechaNacimientoFormateada,
      'direccion': asociado.direccion,
      'estadoCivil': asociado.estadoCivil,
      'fechaIngreso': asociado.fechaIngresoFormateada,
      'estado': asociado.estado,
      'plan': asociado.plan,
      'cargasFamiliares': [],
    };
  }
}