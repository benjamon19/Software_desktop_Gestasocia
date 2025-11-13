import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/historial_clinico_controller.dart';

// Importaciones para la vista de lista
import 'sections/search_section/search_section.dart';
import 'sections/historial_list_section/historial_list_section.dart';
import 'sections/form_section/form_section.dart';
import 'shared/widgets/loading_indicator.dart';

// Importaciones para la vista de detalle
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
              Expanded(
                child: _buildMainContent(controller),
              ),
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
    } else {
      return FloatingActionButton(
        mini: true,
        onPressed: controller.showListView,
        backgroundColor: Colors.grey[600],
        foregroundColor: Colors.white,
        tooltip: 'Volver a la lista',
        child: const Icon(Icons.arrow_back, size: 20),
      );
    }
  }

  Widget _buildMainContent(HistorialClinicoController controller) {
    if (controller.isDetailView) {
      return _buildDetailView(controller);
    }

    // Vista de lista: lista + formulario
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Columna de la lista + buscador
        Expanded(
          flex: 1,
          child: Column(
            children: [
              SearchSection(controller: controller),
              const SizedBox(height: 20),

              // Lista de historiales
              Expanded(
                child: HistorialListSection(
                  historiales: controller.filteredHistorial,
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
                  onOdontologoChanged: controller.setOdontologo,
                  selectedFilter: controller.selectedFilter.value,
                  selectedStatus: controller.selectedStatus.value,
                  selectedOdontologo: controller.selectedOdontologo.value,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 20),

        // Formulario al lado derecho
        Expanded(
          flex: 1,
          child: FormSection(controller: controller),
        ),
      ],
    );
  }

  Widget _buildDetailView(HistorialClinicoController controller) {
    // ✅ Corrección: controller.selectedHistorial.value podría ser null, pero en vista de detalle no debería
    // Usamos `!` con seguridad porque solo se llama si hay un historial seleccionado
final String historialId = controller.selectedHistorial.value?.id ?? 'temp_id';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Columna principal con scroll
        Expanded(
          flex: 2,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      HistorialHeader(historial: controller.toDisplayMap(controller.selectedHistorial.value!)),
                      
                      const SizedBox(height: 20),
                      
                      // Datos Clínicos
                      ClinicalDataCard(historial: controller.toDisplayMap(controller.selectedHistorial.value!)),
                      
                      const SizedBox(height: 20),
                      
                      // Imagen / Radiografía → ✅ PASAMOS SOLO EL ID
                      ImageUploadCard(historialId: historialId),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        
        const SizedBox(width: 20),
        
        // Panel de acciones (sin scroll, fijo)
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