import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/app_theme.dart';
import '../../../../controllers/asociados_controller.dart';
import '../../../../models/asociado.dart';
import 'sections/search_section/search_section.dart';
import 'sections/profile_section/profile_section.dart';
import 'sections/actions_section/actions_section.dart';
import 'sections/empty_state_section/empty_state_section.dart';
import 'sections/asociados_list_section/asociados_list_section.dart';
import 'shared/widgets/loading_indicator.dart';

class AsociadosMainView extends StatelessWidget {
  const AsociadosMainView({super.key});

  @override
  Widget build(BuildContext context) {
    final AsociadosController controller = Get.find<AsociadosController>();

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Obx(() {
          // Si está cargando, mostrar pantalla completa de carga
          if (controller.isLoading.value) {
            return const LoadingIndicator(message: 'Cargando asociados...');
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Solo mostrar SearchSection cuando NO hay asociado seleccionado
              if (!controller.hasSelectedAsociado)
                Column(
                  children: [
                    SearchSection(controller: controller),
                    const SizedBox(height: 20),
                  ],
                ),
              
              Expanded(
                child: _buildMainContent(context, controller),
              ),
            ],
          );
        }),
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
    if (controller.hasSelectedAsociado) {
      return _buildProfileView(controller);
    }

    if (controller.hasAsociados) {
      return AsociadosListSection(
        asociados: controller.asociados,
        onAsociadoSelected: (asociado) => _selectAsociado(controller, asociado),
        controller: controller,
      );
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

  void _selectAsociado(AsociadosController controller, Asociado asociado) {
    controller.selectedAsociado.value = asociado;
    controller.searchQuery.value = '';
  }

  void _goBackToList(AsociadosController controller) {
    controller.selectedAsociado.value = null;
    controller.resetFilter();
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