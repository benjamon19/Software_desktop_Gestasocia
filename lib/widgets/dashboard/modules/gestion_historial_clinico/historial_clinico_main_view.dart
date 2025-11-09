import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/app_theme.dart';
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
        // Si está en vista de detalle, mostrar el layout de detalle
        if (controller.isDetailView && controller.hasSelectedHistorial) {
          return _buildDetailLayout(context, controller);
        }

        // Si está en vista de lista, mostrar el layout principal (3 columnas)
        return _buildMainLayout(context, controller);
      }),
    );
  }

  // Layout principal con 3 columnas (Búsqueda + Lista | Formulario)
  Widget _buildMainLayout(BuildContext context, HistorialClinicoController controller) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // COLUMNA IZQUIERDA: Búsqueda + Lista (1/3 del ancho - MÁS PEQUEÑO)
        Expanded(
          flex: 1,
          child: Column(
            children: [
              // SECCIÓN DE BÚSQUEDA (parte superior izquierda)
              SearchSection(controller: controller),

              const SizedBox(height: 20),

              // SECCIÓN DE LISTA (parte inferior izquierda)
              Expanded(
                child: _buildListContent(context, controller),
              ),
            ],
          ),
        ),

        const SizedBox(width: 20),

        // COLUMNA DERECHA: Formulario (2/3 del ancho - MÁS GRANDE)
        Expanded(
          flex: 2,
          child: FormSection(controller: controller),
        ),
      ],
    );
  }

  // Layout de detalle (sin secciones adicionales)
  Widget _buildDetailLayout(BuildContext context, HistorialClinicoController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header con botón volver
        Row(
          children: [
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
            const Spacer(),
            Text(
              'Historial de ${controller.selectedHistorial.value!['pacienteNombre']}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.getTextPrimary(context),
              ),
            ),
            const Spacer(),
            const SizedBox(width: 100), // Espacio para balance visual
          ],
        ),

        const SizedBox(height: 30),

        // Contenedor vacío para mantener estructura
        Expanded(
          child: Center(
            child: Text(
              'Sin detalles disponibles',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.getTextSecondary(context),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Contenido de la lista (parte inferior de la columna izquierda)
  Widget _buildListContent(BuildContext context, HistorialClinicoController controller) {
    if (controller.isLoading.value) {
      return const LoadingIndicator(message: 'Cargando historial clínico...');
    }

    return HistorialListSection(
      historiales: controller.filteredHistorial,
      onHistorialSelected: controller.selectHistorial,
      onFilterChanged: controller.setFilter,
      onStatusChanged: controller.setStatus,
      onOdontologoChanged: controller.setOdontologo,
      selectedFilter: controller.selectedFilter.value,
      selectedStatus: controller.selectedStatus.value,
      selectedOdontologo: controller.selectedOdontologo.value,
    );
  }
}
