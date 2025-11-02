import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/app_theme.dart';
import '../../../../controllers/cargas_familiares_controller.dart' as cargas_controller;
import 'sections/metrics_section/metrics_section.dart';
import 'sections/pending_actions_section/pending_actions_section.dart';
import 'sections/search_section/search_section.dart';
import 'sections/carga_detail_section/carga_detail_section.dart';
import 'sections/actions_section/actions_section.dart';
import 'sections/cargas_list_section/cargas_list_section.dart';
import 'shared/widgets/loading_indicator.dart';

class CargasFamiliaresMainView extends StatelessWidget {
  const CargasFamiliaresMainView({super.key});

  @override
  Widget build(BuildContext context) {
    final cargas_controller.CargasFamiliaresController controller =
        Get.put(cargas_controller.CargasFamiliaresController());

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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  controller.hasSelectedCarga
                      ? 'Información completa y gestión de la carga familiar'
                      : 'Gestión y control de cargas familiares',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.getTextSecondary(context),
                  ),
                ),
              ],
            ),
            if (controller.hasSelectedCarga)
              OutlinedButton.icon(
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
          ],
        ));
  }

  Widget _buildMainContent(BuildContext context, cargas_controller.CargasFamiliaresController controller) {
    if (controller.isLoading.value) {
      return const LoadingIndicator(message: 'Cargando cargas familiares...');
    }

    if (controller.hasSelectedCarga) {
      return _buildDetailView(controller);
    }

    return _buildDashboardView(context, controller);
  }

  Widget _buildDetailView(cargas_controller.CargasFamiliaresController controller) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: CargaDetailSection(
            carga: controller.selectedCarga.value!,
            onEdit: controller.editCarga,
          ),
        ),
        const SizedBox(width: 20),
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

  Widget _buildDashboardView(BuildContext context, cargas_controller.CargasFamiliaresController controller) {
    return Column(
      children: [
        const MetricsSection(),
        const SizedBox(height: 30),

        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    SearchSection(controller: controller),
                    const SizedBox(height: 20),

                    Expanded(
                      child: CargasListSection(
                        cargas: controller.filteredCargas.toList(),
                        onCargaSelected: (carga) => controller.selectCarga(carga),
                        controller: controller,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 20),

              Expanded(
                flex: 1,
                child: PendingActionsSection(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}