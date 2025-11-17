import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../../controllers/asociados_controller.dart';
import '../../../../../../../utils/app_theme.dart';

class ProfileHeader extends StatelessWidget {
  final Map<String, dynamic> asociado;
  final VoidCallback onEdit;
  final VoidCallback? onBack;

  const ProfileHeader({
    super.key,
    required this.asociado,
    required this.onEdit,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final AsociadosController controller = Get.find<AsociadosController>();
    
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
            AppTheme.primaryColor,
            AppTheme.primaryColor.withValues(alpha: 0.8),
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
            final currentAsociado = controller.selectedAsociado.value;
            if (currentAsociado == null) {
              return const SizedBox();
            }
            
            return isVerySmall 
              ? _buildCompactLayout(currentAsociado, isVerySmall)
              : _buildNormalLayout(currentAsociado, isSmallScreen);
          }),
        ],
      ),
    );
  }

  Widget _buildNormalLayout(dynamic currentAsociado, bool isSmallScreen) {
    return Row(
      children: [
        _buildAvatar(isSmallScreen, false),
        SizedBox(width: isSmallScreen ? 12 : 16),
        Expanded(
          child: _buildBasicInfo(currentAsociado, isSmallScreen, false),
        ),
      ],
    );
  }

  Widget _buildCompactLayout(dynamic currentAsociado, bool isVerySmall) {
    return Row(
      children: [
        _buildAvatar(false, isVerySmall),
        const SizedBox(width: 12),
        Expanded(
          child: _buildBasicInfo(currentAsociado, false, isVerySmall),
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
        Icons.person,
        size: iconSize,
        color: Colors.white.withValues(alpha: 0.9),
      ),
    );
  }

  Widget _buildBasicInfo(dynamic currentAsociado, bool isSmallScreen, bool isVerySmall) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          currentAsociado.nombreCompleto,
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
        
        Row(
          children: [
            // RUT
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
                'RUT: ${currentAsociado.rut}',
                style: TextStyle(
                  fontSize: isVerySmall ? 10 : 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.95),
                ),
              ),
            ),

            SizedBox(width: 6),

            // SAP
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
                'SAP: ${currentAsociado.sap}',
                style: TextStyle(
                  fontSize: isVerySmall ? 10 : 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.95),
                ),
              ),
            ),
          ],
        ),
        
        SizedBox(height: isVerySmall ? 6 : 8),
        
        Row(
          children: [
            _buildStatusBadge(currentAsociado.estado, isVerySmall),
            const SizedBox(width: 6),
            _buildPlanBadge(currentAsociado.plan, isVerySmall),
          ],
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

  Widget _buildPlanBadge(String plan, bool isVerySmall) {
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
        plan,
        style: TextStyle(
          fontSize: isVerySmall ? 9 : 10,
          fontWeight: FontWeight.w600,
          color: Colors.white.withValues(alpha: 0.95),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'activo':
        return const Color(0xFF059669);
      case 'inactivo':
        return const Color(0xFFDC2626);
      case 'suspendido':
        return const Color(0xFFD97706);
      default:
        return const Color(0xFF4B5563);
    }
  }
}
