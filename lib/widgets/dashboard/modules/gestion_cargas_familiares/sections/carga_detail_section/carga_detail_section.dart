// carga_detail_section.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../utils/app_theme.dart';
import '../../../../../../controllers/cargas_familiares_controller.dart';
import 'components/carga_header.dart';
import 'components/personal_info_card.dart';
import 'components/clinical_history_card.dart';

class CargaDetailSection extends StatefulWidget {
  final Map<String, dynamic> carga;
  final VoidCallback onEdit;
  final VoidCallback? onBack;

  const CargaDetailSection({
    super.key,
    required this.carga,
    required this.onEdit,
    this.onBack,
  });

  @override
  State<CargaDetailSection> createState() => _CargaDetailSectionState();
}

class _CargaDetailSectionState extends State<CargaDetailSection> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CargasFamiliaresController controller = Get.find<CargasFamiliaresController>();
    
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
          Obx(() {
            final currentCarga = controller.selectedCarga.value;
            if (currentCarga == null) {
              return const SizedBox();
            }
            return CargaHeader(
              carga: _cargaToMap(currentCarga),
              onEdit: widget.onEdit,
            );
          }),
          
          Expanded(
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Obx(() {
                  final currentCarga = controller.selectedCarga.value;
                  if (currentCarga == null || currentCarga.id == null) {
                    return const SizedBox();
                  }
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PersonalInfoCard(carga: _cargaToMap(currentCarga)),

                      ClinicalHistoryCard(
                        pacienteId: currentCarga.id!,
                        pacienteTipo: 'carga',
                      ),
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

  Map<String, dynamic> _cargaToMap(dynamic carga) {
    return {
      'id': carga.id,
      'nombre': carga.nombre,
      'apellido': carga.apellido,
      'nombreCompleto': carga.nombreCompleto,
      'rut': carga.rut,
      'fechaNacimiento': carga.fechaNacimientoFormateada,
      'edad': carga.edad,
      'parentesco': carga.parentesco,
      'estado': carga.estado,
      'isActive': carga.isActive,
      'fechaCreacion': carga.fechaCreacionFormateada,
      'asociadoId': carga.asociadoId,
    };
  }
}