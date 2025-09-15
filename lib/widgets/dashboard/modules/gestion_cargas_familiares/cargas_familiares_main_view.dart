// lib/widgets/dashboard/modules/gestion_cargas_familiares/cargas_familiares_main_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/app_theme.dart';
import '../../../../controllers/cargas_familiares_controller.dart' as cargas_controller;
import 'sections/metrics_section/metrics_section.dart';
import 'sections/pending_actions_section/pending_actions_section.dart';
import 'sections/search_section/search_section.dart';
import 'sections/carga_detail_section/carga_detail_section.dart';
import 'sections/actions_section/actions_section.dart';
import 'shared/widgets/loading_indicator.dart';

class CargasFamiliaresMainView extends StatelessWidget {
  const CargasFamiliaresMainView({super.key});

  @override
  Widget build(BuildContext context) {
    final cargas_controller.CargasFamiliaresController controller = Get.put(cargas_controller.CargasFamiliaresController());

    return Container(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, controller),
          const SizedBox(height: 30),
          
          Expanded(
            child: Obx(() => _buildMainContent(context, controller)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, cargas_controller.CargasFamiliaresController controller) {
    return Obx(() => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Título y subtítulo
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              _getSubtitle(controller),
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.getTextSecondary(context),
              ),
            ),
          ],
        ),
        
        // Acciones del header
        _buildHeaderActions(context, controller),
      ],
    ));
  }

  String _getSubtitle(cargas_controller.CargasFamiliaresController controller) {
    if (controller.isDetailView) {
      return 'Información completa y gestión de la carga familiar';
    } else {
      return 'Dashboard de gestión y control de cargas familiares';
    }
  }

  Widget _buildHeaderActions(BuildContext context, cargas_controller.CargasFamiliaresController controller) {
    return Obx(() => Row(
      children: [
        // Botón volver (solo en vista detalle)
        if (controller.isDetailView)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: OutlinedButton.icon(
              onPressed: controller.backToList,
              icon: const Icon(Icons.arrow_back, size: 18),
              label: const Text('Volver'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.getTextSecondary(context),
                side: BorderSide(color: AppTheme.getBorderLight(context)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
      ],
    ));
  }

  Widget _buildMainContent(BuildContext context, cargas_controller.CargasFamiliaresController controller) {
    if (controller.isLoading.value) {
      return const LoadingIndicator(message: 'Cargando cargas familiares...');
    }
    
    // Vista de detalle (como el profile de asociados)
    if (controller.isDetailView && controller.hasSelectedCarga) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Detalle de la carga (2/3 del ancho)
          Expanded(
            flex: 2,
            child: CargaDetailSection(
              carga: controller.selectedCarga.value!,
              onEdit: controller.editCarga,
            ),
          ),
          
          const SizedBox(width: 20),
          
          // Panel de acciones (1/3 del ancho)
          Expanded(
            flex: 1,
            child: ActionsSection(
              carga: controller.selectedCarga.value!,
              controller: controller,
            ),
          ),
        ],
      );
    }
    
    // Vista principal con dashboard layout
    return Column(
      children: [
        // Métricas arriba
        const MetricsSection(),
        const SizedBox(height: 30),
        
        // Contenido principal: Acciones pendientes (izq) + Búsqueda/Lista (der)
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Acciones pendientes (2/3)
              const Expanded(
                flex: 2,
                child: PendingActionsSection(),
              ),
              
              const SizedBox(width: 20),
              
              // Búsqueda + Lista (1/3)
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    // Búsqueda compacta
                    SearchSection(controller: controller),
                    const SizedBox(height: 20),
                    
                    // Lista compacta
                    Expanded(
                      child: _buildCompactList(context, controller),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactList(BuildContext context, cargas_controller.CargasFamiliaresController controller) {
    if (controller.filteredCargas.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: AppTheme.getSurfaceColor(context),
          borderRadius: BorderRadius.circular(16),
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
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.group_outlined, size: 48, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Sin resultados',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(16),
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
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16), 
                topRight: Radius.circular(16)
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.list, color: AppTheme.primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Cargas (${controller.filteredCargas.length})',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: controller.filteredCargas.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final carga = controller.filteredCargas[index];
                return _buildCompactCargaItem(context, carga, controller);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactCargaItem(BuildContext context, Map<String, dynamic> carga, cargas_controller.CargasFamiliaresController controller) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => controller.selectCarga(carga),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.getInputBackground(context),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.getBorderLight(context)),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _getParentescoColor(carga['parentesco']).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: _getParentescoColor(carga['parentesco']).withValues(alpha: 0.3)),
                ),
                child: Icon(_getParentescoIcon(carga['parentesco']), 
                          color: _getParentescoColor(carga['parentesco']), size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${carga['nombre']} ${carga['apellido']}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.getTextPrimary(context),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${carga['parentesco']} • ${carga['edad']} años',
                      style: TextStyle(
                        fontSize: 11,
                        color: _getParentescoColor(carga['parentesco']),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, size: 16, color: AppTheme.getTextSecondary(context)),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getParentescoIcon(String parentesco) {
    switch (parentesco.toLowerCase()) {
      case 'hijo': case 'hija': return Icons.child_care;
      case 'cónyuge': return Icons.favorite;
      case 'padre': case 'madre': return Icons.elderly;
      default: return Icons.person;
    }
  }

  Color _getParentescoColor(String parentesco) {
    switch (parentesco.toLowerCase()) {
      case 'hijo': case 'hija': return const Color(0xFF10B981);
      case 'cónyuge': return const Color(0xFFEC4899);
      case 'padre': case 'madre': return const Color(0xFF8B5CF6);
      default: return const Color(0xFF6B7280);
    }
  }
}