import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../utils/app_theme.dart';
import '../../../../../../controllers/asociados_controller.dart';
import 'components/profile_header.dart';
import 'components/personal_info_card.dart';
import 'components/family_charges_card.dart';

class ProfileSection extends StatefulWidget {
  final Map<String, dynamic> asociado; // Mantenemos por compatibilidad
  final VoidCallback onEdit;
  final VoidCallback? onBack;

  const ProfileSection({
    super.key,
    required this.asociado,
    required this.onEdit,
    this.onBack,
  });

  @override
  State<ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends State<ProfileSection> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsociadosController controller = Get.find<AsociadosController>();
    
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
          // Header del perfil - AHORA COMPLETAMENTE REACTIVO
          Obx(() {
            final currentAsociado = controller.selectedAsociado.value;
            if (currentAsociado == null) {
              return const SizedBox();
            }
            return ProfileHeader(
              asociado: _asociadoToMap(currentAsociado), // Convertir para compatibilidad
              onEdit: widget.onEdit,
            );
          }),
          
          // Contenido scrolleable - TAMBIÉN REACTIVO
          Expanded(
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Obx(() {
                  final currentAsociado = controller.selectedAsociado.value;
                  if (currentAsociado == null) {
                    return const SizedBox();
                  }
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Información personal - REACTIVA
                      PersonalInfoCard(asociado: _asociadoToMap(currentAsociado)),
                      
                      // Cargas familiares - REACTIVA
                      FamilyChargesCard(asociado: currentAsociado),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Convertir Asociado a Map para compatibilidad con componentes existentes
  Map<String, dynamic> _asociadoToMap(dynamic asociado) {
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
      'cargasFamiliares': [], // Por ahora vacío hasta implementar cargas
    };
  }
}