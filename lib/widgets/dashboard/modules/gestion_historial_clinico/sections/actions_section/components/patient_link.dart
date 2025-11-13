import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../../utils/app_theme.dart';
import '../../../../../../../controllers/asociados_controller.dart';
import '../../../../../../../controllers/cargas_familiares_controller.dart';
import '../../../../../../../controllers/dashboard_page_controller.dart';
import '../../../shared/widgets/section_title.dart';

class PatientLink extends StatelessWidget {
  final Map<String, dynamic> historial;

  const PatientLink({
    super.key,
    required this.historial,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 400;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle(title: 'Paciente'),
            const SizedBox(height: 12),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _goToPatientProfile,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(isCompact ? 12 : 16),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(
                      color: AppTheme.getBorderLight(context).withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Fila principal
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildAvatar(context),
                          SizedBox(width: isCompact ? 10 : 16),
                          Expanded(child: _buildPatientInfo(context)),
                          Icon(
                            Icons.chevron_right,
                            size: 18,
                            color: AppTheme.getTextSecondary(context),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      Divider(
                        height: 1,
                        color: AppTheme.getBorderLight(context).withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 12),

                      // Ver perfil
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.arrow_forward,
                              size: 16, color: AppTheme.primaryColor),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Ver perfil completo',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final tipo = historial['pacienteTipo'];
    final pacienteId = historial['pacienteId'];

    bool estaActivo = true;
    IconData iconData = Icons.person;

    if (tipo == 'asociado') {
      try {
        final asociadosController = Get.find<AsociadosController>();
        final asociado = asociadosController.getAsociadoById(pacienteId);
        if (asociado != null) {
          estaActivo = asociado.estaActivo;
        }
      } catch (_) {}
    } else if (tipo == 'carga') {
      try {
        final cargasController = Get.find<CargasFamiliaresController>();
        final carga = cargasController.getCargaById(pacienteId);
        if (carga != null) {
          estaActivo = carga.estaActivo;
          iconData = _getParentescoIcon(carga.parentesco);
        }
      } catch (_) {}
    }

    return Stack(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.getBorderLight(context),
              width: 1,
            ),
          ),
          child: Icon(
            iconData,
            size: 24,
            color: Colors.grey.shade600,
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: estaActivo
                  ? const Color(0xFF10B981)
                  : const Color(0xFFEF4444),
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).scaffoldBackgroundColor,
                width: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPatientInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nombre del paciente
        Text(
          historial['pacienteNombre'] ?? 'Sin nombre',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextPrimary(context),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),

        // RUT y tipo de paciente
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.badge, size: 12, color: AppTheme.getTextSecondary(context)),
                const SizedBox(width: 4),
                Text(
                  historial['pacienteRut'] ?? 'Sin RUT',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.getTextSecondary(context),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getTipoPacienteColor(historial['pacienteTipo']).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _getTipoPacienteLabel(historial['pacienteTipo']),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: _getTipoPacienteColor(historial['pacienteTipo']),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  IconData _getParentescoIcon(String? parentesco) {
    if (parentesco == null) return Icons.person;
    switch (parentesco.toLowerCase()) {
      case 'hijo':
        return Icons.boy;
      case 'hija':
        return Icons.girl;
      case 'cónyuge':
        return Icons.favorite;
      case 'padre':
      case 'madre':
        return Icons.elderly;
      default:
        return Icons.person;
    }
  }

  void _goToPatientProfile() {
    try {
      final tipo = historial['pacienteTipo'];
      final pacienteId = historial['pacienteId'];

      if (tipo == 'asociado') {
        final asociadosController = Get.find<AsociadosController>();
        final asociado = asociadosController.getAsociadoById(pacienteId);
        if (asociado != null) {
          asociadosController.selectedAsociado.value = asociado;
          Get.find<DashboardPageController>().changeModule(1);
        } else {
          Get.snackbar('Error', 'No se encontró el asociado',
              snackPosition: SnackPosition.BOTTOM);
        }
      } else if (tipo == 'carga') {
        final cargasController = Get.find<CargasFamiliaresController>();
        final carga = cargasController.getCargaById(pacienteId);
        if (carga != null) {
          final cargaMap = {
            'id': carga.id,
            'nombre': carga.nombre,
            'apellido': carga.apellido,
            'nombreCompleto': carga.nombreCompleto,
            'rut': carga.rut,
            'rutFormateado': carga.rutFormateado,
            'parentesco': carga.parentesco,
            'edad': carga.edad,
            'fechaNacimiento': carga.fechaNacimientoFormateada,
            'fechaCreacion': carga.fechaCreacionFormateada,
            'estado': carga.estado,
            'isActive': carga.isActive,
            'asociadoId': carga.asociadoId,
          };
          cargasController.selectCarga(cargaMap);
          Get.find<DashboardPageController>().changeModule(2);
        } else {
          Get.snackbar('Error', 'No se encontró la carga familiar',
              snackPosition: SnackPosition.BOTTOM);
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'No se pudo abrir el perfil del paciente',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  String _getTipoPacienteLabel(String? tipo) {
    if (tipo == null) return 'Asociado';
    switch (tipo.toLowerCase()) {
      case 'asociado':
        return 'Asociado';
      case 'carga':
        return 'Carga Familiar';
      default:
        return tipo;
    }
  }

  Color _getTipoPacienteColor(String? tipo) {
    if (tipo == null) return const Color(0xFF3B82F6);
    switch (tipo.toLowerCase()) {
      case 'asociado':
        return const Color(0xFF3B82F6);
      case 'carga':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF6B7280);
    }
  }
}
