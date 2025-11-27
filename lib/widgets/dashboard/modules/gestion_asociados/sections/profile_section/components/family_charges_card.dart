import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../../utils/app_theme.dart';
import '../../../../../../../controllers/asociados_controller.dart';
import '../../../../../../../controllers/cargas_familiares_controller.dart';
import '../../../../../../../controllers/dashboard_page_controller.dart';
import '../../../../../../../models/asociado.dart';

class FamilyChargesCard extends StatefulWidget {
  final Asociado asociado;

  const FamilyChargesCard({
    super.key,
    required this.asociado,
  });

  @override
  State<FamilyChargesCard> createState() => _FamilyChargesCardState();
}

class _FamilyChargesCardState extends State<FamilyChargesCard> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsociadosController controller = Get.find<AsociadosController>();
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() {
            final asociadoId = widget.asociado.id;
            
            if (asociadoId == null) {
              return const SizedBox();
            }
            
            final cargasDelAsociado = controller.cargasFamiliares
                .where((carga) => carga.asociadoId == asociadoId)
                .toList();
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(context, cargasDelAsociado.length),
                const SizedBox(height: 16),
                _buildChargesContent(context, cargasDelAsociado),
                if (cargasDelAsociado.length > 5) _buildScrollHint(context),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, int chargesCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.family_restroom,
                color: Color(0xFF10B981),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Cargas Familiares',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextPrimary(context),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$chargesCount',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF10B981),
                ),
              ),
            ),
            if (chargesCount > 5)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: AppTheme.getTextSecondary(context),
                  size: 16,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildChargesContent(BuildContext context, List<dynamic> cargas) {
    if (cargas.isEmpty) {
      return _buildEmptyState(context);
    }
    
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: cargas.length > 5 ? 400 : double.infinity,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.getSurfaceColor(context),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppTheme.getBorderLight(context).withValues(alpha: 0.5),
          ),
        ),
        child: Scrollbar(
          controller: _scrollController,
          thumbVisibility: cargas.length > 5,
          child: ListView.separated(
            controller: _scrollController,
            shrinkWrap: true,
            physics: cargas.length > 5 
                ? const AlwaysScrollableScrollPhysics() 
                : const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(8),
            itemCount: cargas.length,
            separatorBuilder: (context, index) => const SizedBox(height: 6),
            itemBuilder: (context, index) {
              final carga = cargas[index];
              return _buildFamilyChargeItem(context, carga);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getInputBackground(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.getBorderLight(context),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppTheme.getTextSecondary(context),
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            'No hay cargas familiares registradas',
            style: TextStyle(
              color: AppTheme.getTextSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyChargeItem(BuildContext context, dynamic carga) {
    final hovered = false.obs;

    return ObxValue<RxBool>(
      (hover) => InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _goToCargaProfile(carga),
        onHover: (value) => hover.value = value,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: hover.value
                ? AppTheme.primaryColor.withAlpha(10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              _buildCargaAvatar(context, carga),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCargaInfo(context, carga),
              ),
              Icon(
                Icons.chevron_right,
                size: 16,
                color: AppTheme.getTextSecondary(context),
              ),
            ],
          ),
        ),
      ),
      hovered,
    );
  }

  Widget _buildCargaAvatar(BuildContext context, dynamic carga) {
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
            _getParentescoIcon(carga.parentesco),
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
              color: carga.estaActivo
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

  Widget _buildCargaInfo(BuildContext context, dynamic carga) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          carga.nombreCompleto,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextPrimary(context),
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Icon(Icons.badge, size: 12, color: AppTheme.getTextSecondary(context)),
            const SizedBox(width: 4),
            Text(
              carga.rutFormateado,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.getTextSecondary(context),
              ),
            ),
            const SizedBox(width: 12),
            Icon(Icons.favorite_outline, size: 12, color: AppTheme.getTextSecondary(context)),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                '${carga.parentesco} • ${carga.edad} años',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.getTextSecondary(context),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScrollHint(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Center(
        child: Text(
          'Scrollea para ver más cargas familiares',
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.getTextSecondary(context),
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  void _goToCargaProfile(dynamic carga) {
    try {
      final CargasFamiliaresController cargasController = Get.find<CargasFamiliaresController>();
      
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
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo abrir el perfil de la carga familiar',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
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
}