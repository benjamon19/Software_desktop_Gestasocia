import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../../controllers/cargas_familiares_controller.dart';
import '../../../../../../../controllers/asociados_controller.dart';

class CargaHeader extends StatelessWidget {
  final Map<String, dynamic> carga;
  final VoidCallback onEdit;
  final VoidCallback? onBack;

  const CargaHeader({
    super.key,
    required this.carga,
    required this.onEdit,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final CargasFamiliaresController controller = Get.find<CargasFamiliaresController>();
    
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 600;
    final bool isVerySmall = screenWidth < 400;
    
    return Container(
      padding: EdgeInsets.all(isVerySmall ? 16 : (isSmallScreen ? 20 : 24)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF10B981),
            const Color(0xFF10B981).withValues(alpha: 0.8),
          ],
          stops: const [0.0, 1.0],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (onBack != null)
                IconButton(
                  onPressed: onBack,
                  icon: Icon(
                    Icons.arrow_back, 
                    color: Colors.white,
                    size: isVerySmall ? 20 : 24,
                  ),
                  tooltip: 'Volver a la lista',
                  padding: EdgeInsets.all(isVerySmall ? 8 : 12),
                ),
              if (onBack == null) SizedBox(width: isVerySmall ? 32 : 48),
            ],
          ),
          
          SizedBox(height: isVerySmall ? 4 : 8),
          
          Obx(() {
            final currentCarga = controller.selectedCarga.value;
            if (currentCarga == null) {
              return const SizedBox();
            }
            
            return isVerySmall 
              ? _buildCompactLayout(currentCarga, isVerySmall)
              : _buildNormalLayout(currentCarga, isSmallScreen);
          }),
        ],
      ),
    );
  }

  Widget _buildNormalLayout(dynamic currentCarga, bool isSmallScreen) {
    return Row(
      children: [
        _buildAvatar(isSmallScreen, false),
        
        SizedBox(width: isSmallScreen ? 12 : 16),
        
        Expanded(
          child: _buildBasicInfo(currentCarga, isSmallScreen, false),
        ),
      ],
    );
  }

  Widget _buildCompactLayout(dynamic currentCarga, bool isVerySmall) {
    return Row(
      children: [
        _buildAvatar(false, isVerySmall),
        
        const SizedBox(width: 12),
        
        Expanded(
          child: _buildBasicInfo(currentCarga, false, isVerySmall),
        ),
      ],
    );
  }

  Widget _buildAvatar(bool isSmallScreen, bool isVerySmall) {
    final avatarSize = isVerySmall ? 45.0 : (isSmallScreen ? 55.0 : 65.0);
    final iconSize = isVerySmall ? 22.0 : (isSmallScreen ? 28.0 : 35.0);
    final borderWidth = isVerySmall ? 2.0 : 2.5;
    
    return Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: isVerySmall ? 3 : 6,
            offset: Offset(0, isVerySmall ? 1 : 3),
          ),
        ],
      ),
      child: Icon(
        _getParentescoIcon(carga['parentesco']),
        size: iconSize,
        color: Colors.white.withValues(alpha: 0.9),
      ),
    );
  }

  Widget _buildBasicInfo(dynamic currentCarga, bool isSmallScreen, bool isVerySmall) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          currentCarga.nombreCompleto,
          style: TextStyle(
            fontSize: isVerySmall ? 16 : (isSmallScreen ? 18 : 20),
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -0.3,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        
        SizedBox(height: isVerySmall ? 3 : 4),
        
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isVerySmall ? 6 : 8,
            vertical: isVerySmall ? 2 : 3,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'RUT: ${_formatearRut(currentCarga.rut)}',
            style: TextStyle(
              fontSize: isVerySmall ? 10 : 11,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.95),
            ),
          ),
        ),
        
        SizedBox(height: isVerySmall ? 6 : 8),
        
        Row(
          children: [
            _buildStatusBadge(currentCarga.estado, isVerySmall),
            const SizedBox(width: 6),
            _buildParentescoBadge(currentCarga.parentesco, isVerySmall),
            const SizedBox(width: 6),
            _buildAgeBadge(currentCarga.edad, isVerySmall),
          ],
        ),
        
        SizedBox(height: isVerySmall ? 6 : 8),
        
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isVerySmall ? 6 : 8,
            vertical: isVerySmall ? 2 : 3,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'Carga de: ${_getAsociadoNombre(currentCarga.asociadoId)}',
            style: TextStyle(
              fontSize: isVerySmall ? 9 : 10,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.9),
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status, bool isVerySmall) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isVerySmall ? 6 : 8,
        vertical: isVerySmall ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: _getStatusColor(status),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isVerySmall ? 4 : 5,
            height: isVerySmall ? 4 : 5,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: isVerySmall ? 3 : 4),
          Text(
            status,
            style: TextStyle(
              fontSize: isVerySmall ? 9 : 10,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParentescoBadge(String parentesco, bool isVerySmall) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isVerySmall ? 6 : 8,
        vertical: isVerySmall ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        parentesco,
        style: TextStyle(
          fontSize: isVerySmall ? 9 : 10,
          fontWeight: FontWeight.w600,
          color: Colors.white.withValues(alpha: 0.95),
        ),
      ),
    );
  }

  Widget _buildAgeBadge(int edad, bool isVerySmall) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isVerySmall ? 6 : 8,
        vertical: isVerySmall ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        '$edad años',
        style: TextStyle(
          fontSize: isVerySmall ? 9 : 10,
          fontWeight: FontWeight.w600,
          color: Colors.white.withValues(alpha: 0.95),
        ),
      ),
    );
  }

  String _formatearRut(String rutRaw) {
    final clean = rutRaw.replaceAll(RegExp(r'[^0-9kK]'), '').toUpperCase();
    if (clean.isEmpty) return '';
    if (clean.length <= 1) return clean;
    
    String cuerpo = clean.substring(0, clean.length - 1);
    String dv = clean.substring(clean.length - 1);
    
    cuerpo = cuerpo.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    
    return '$cuerpo-$dv';
  }

  String _getAsociadoNombre(String? asociadoId) {
    if (asociadoId == null || asociadoId.isEmpty) return 'Sin titular';
    try {
      final AsociadosController asociadosController = Get.find<AsociadosController>();
      final asociado = asociadosController.getAsociadoById(asociadoId);
      if (asociado != null) return asociado.nombreCompleto;
    } catch (e) {
      // Error silencioso
    }
    return 'Titular desconocido';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'activa':
        return const Color(0xFF059669);
      case 'inactiva':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF4B5563);
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