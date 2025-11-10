import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/historial_clinico_controller.dart';
import 'sections/search_section/search_section.dart';
import 'sections/historial_list_section/historial_list_section.dart';
import 'shared/widgets/loading_indicator.dart';
import 'sections/form_section/form_section.dart';

class HistorialClinicoMainView extends StatelessWidget {
  const HistorialClinicoMainView({super.key});

  @override
  Widget build(BuildContext context) {
    final HistorialClinicoController controller = Get.put(HistorialClinicoController());

    return Container(
      padding: const EdgeInsets.all(20),
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: LoadingIndicator(message: 'Cargando historial clínico...'),
          );
        }

        return _buildMainLayout(context, controller);
      }),
    );
  }

  Widget _buildMainLayout(BuildContext context, HistorialClinicoController controller) {
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
                  historiales: controller.filteredHistorial,
                  onHistorialSelected: controller.selectHistorial,
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

        // Columna derecha: Formulario para nuevo historial
        Expanded(
          flex: 1,
          child: FormSection(controller: controller),
        ),
      ],
    );
  }
}