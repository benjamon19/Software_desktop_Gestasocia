import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/cargas_familiares_controller.dart' as cargas_controller;
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

    return Scaffold(
      body: Obx(() {
        // Si está cargando, mostrar SOLO el loading centrado
        if (controller.isLoading.value) {
          return const LoadingIndicator(message: 'Cargando cargas familiares...');
        }

        // Si no está cargando, mostrar el contenido principal con padding
        return Container(
          padding: const EdgeInsets.all(20),
          child: _buildMainContent(context, controller),
        );
      }),
      floatingActionButton: Obx(() => _buildFloatingActionButton(controller)),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildFloatingActionButton(cargas_controller.CargasFamiliaresController controller) {
    if (!controller.hasSelectedCarga) {
      return const SizedBox.shrink();
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

  Widget _buildMainContent(BuildContext context, cargas_controller.CargasFamiliaresController controller) {
    if (controller.hasSelectedCarga) {
      return _buildDetailView(controller);
    }
    return _buildDashboardView(context, controller);
  }

  Widget _buildDetailView(cargas_controller.CargasFamiliaresController controller) {
    final carga = controller.selectedCarga.value!;
    final cargaMap = _cargaToMap(carga);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: CargaDetailSection(
            carga: cargaMap,
            onEdit: controller.editCarga,
            onBack: () => _goBackToList(controller),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          flex: 1,
          child: ActionsSection(
            carga: cargaMap,
            controller: controller,
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardView(BuildContext context, cargas_controller.CargasFamiliaresController controller) {
    return Row(
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
        const Expanded(
          flex: 1,
          child: PendingActionsSection(),
        ),
      ],
    );
  }

  void _goBackToList(cargas_controller.CargasFamiliaresController controller) {
    controller.backToList();
  }

  Map<String, dynamic> _cargaToMap(dynamic carga) {
    final map = carga.toMap();
    map['id'] = carga.id;
    map['edad'] = carga.edad;
    map['estado'] = carga.estado;
    map['rutFormateado'] = carga.rutFormateado;
    map['nombreCompleto'] = carga.nombreCompleto;
    map['fechaNacimientoFormateada'] = carga.fechaNacimientoFormateada;
    map['fechaCreacionFormateada'] = carga.fechaCreacionFormateada;
    return map;
  }
}
