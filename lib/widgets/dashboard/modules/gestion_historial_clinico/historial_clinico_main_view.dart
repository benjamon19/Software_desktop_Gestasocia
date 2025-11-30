import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../controllers/historial_clinico_controller.dart';

// Vista de lista
import 'sections/search_section/search_section.dart';
import 'sections/historial_list_section/historial_list_section.dart';
import 'sections/form_section/form_section.dart';
import 'shared/widgets/loading_indicator.dart';

// Vista de detalle
import 'sections/detail_section/components/historial_header.dart';
import 'sections/detail_section/components/clinical_data_card.dart';
import 'sections/detail_section/components/image_upload_card.dart';
import 'sections/actions_section/actions_section.dart';

class HistorialClinicoMainView extends StatelessWidget {
  const HistorialClinicoMainView({super.key});

  @override
  Widget build(BuildContext context) {
    final HistorialClinicoController controller = Get.put(HistorialClinicoController());

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: LoadingIndicator(message: 'Cargando historial clínico...'),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildMainContent(controller)),
            ],
          );
        }),
      ),
      floatingActionButton: Obx(() => _buildFloatingActionButton(controller)),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildFloatingActionButton(HistorialClinicoController controller) {
    if (controller.isListView) {
      return const SizedBox.shrink();
    }

    return FloatingActionButton(
      mini: true,
      onPressed: controller.showListView,
      backgroundColor: Colors.grey[600],
      foregroundColor: Colors.white,
      tooltip: 'Volver a la lista',
      child: const Icon(Icons.arrow_back, size: 20),
    );
  }

  Widget _buildMainContent(HistorialClinicoController controller) {
    if (controller.isDetailView) {
      return _buildDetailView(controller);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Column(
            children: [
              SearchSection(controller: controller),
              const SizedBox(height: 20),
              Expanded(
                child: HistorialListSection(
                  historiales: controller.filteredHistorialList,
                  onHistorialSelected: (historialMap) {
                    final historialCompleto = controller.allHistoriales.firstWhereOrNull(
                      (h) => h.id == historialMap['id'],
                    );

                    if (historialCompleto != null) {
                      controller.showDetailView(historialCompleto);
                    }
                  },
                  onFilterChanged: controller.setFilter,
                  onStatusChanged: controller.setStatus,
                  selectedFilter: controller.selectedFilter.value,
                  selectedStatus: controller.selectedStatus.value,
                  onBeforeSelect: () {
                    controller.clearSearch();
                    controller.setFilter('todos');
                    controller.setStatus('todos');
                  },
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 20),

        Expanded(
          flex: 1,
          child: FormSection(controller: controller),
        ),
      ],
    );
  }

  Widget _buildDetailView(HistorialClinicoController controller) {
    final String historialId = controller.selectedHistorial.value?.id ?? 'temp_id';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HistorialHeader(
                        historial: controller.toDisplayMap(controller.selectedHistorial.value!),
                      ),
                      const SizedBox(height: 20),
                      ClinicalDataCard(
                        historial: controller.toDisplayMap(controller.selectedHistorial.value!),
                      ),
                      const SizedBox(height: 20),
                      ImageUploadCard(historialId: historialId),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(width: 20),

        Expanded(
          flex: 1,
          child: ActionsSection(
            historial: controller.toDisplayMap(controller.selectedHistorial.value!),
            controller: controller,
          ),
        ),
      ],
    );
  }
}