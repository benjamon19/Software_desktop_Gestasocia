import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../../utils/app_theme.dart';
import '../../../../../../../controllers/historial_clinico_controller.dart';

class ImageUploadCard extends StatelessWidget {
  final String historialId;

  const ImageUploadCard({
    super.key,
    required this.historialId,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HistorialClinicoController>();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        border: Border(
          left: BorderSide(color: AppTheme.getBorderLight(context).withValues(alpha: 0.3), width: 1),
          right: BorderSide(color: AppTheme.getBorderLight(context).withValues(alpha: 0.3), width: 1),
          bottom: BorderSide(color: AppTheme.getBorderLight(context).withValues(alpha: 0.3), width: 1),
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.image_outlined,
                  color: Colors.purple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Imagen / Radiografía',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getTextPrimary(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Obx(() {
            final currentHistorial = controller.selectedHistorial.value;
            if (currentHistorial == null || currentHistorial.id != historialId) {
              return _buildEmptyState(context);
            }

            if (currentHistorial.imagenUrl != null && currentHistorial.imagenUrl!.isNotEmpty) {
              return _buildImagePreview(context, currentHistorial.imagenUrl!);
            } else {
              return _buildEmptyState(context);
            }
          }),
        ],
      ),
    );
  }

  Widget _buildImagePreview(BuildContext context, String imageUrl) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.getBorderLight(context).withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrl,
          width: double.infinity,
          fit: BoxFit.fitWidth,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 200,
              alignment: Alignment.center,
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.purple),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppTheme.getBackgroundColor(context),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.broken_image_outlined,
                      size: 48,
                      color: AppTheme.getTextSecondary(context).withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Error al cargar la imagen',
                      style: TextStyle(
                        color: AppTheme.getTextSecondary(context),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isVerySmall = screenWidth < 400;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isVerySmall ? 40 : 60,
        horizontal: 24,
      ),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.getBorderLight(context).withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.image_outlined,
                size: isVerySmall ? 40 : 48,
                color: Colors.purple.withValues(alpha: 0.5),
              ),
            ),
            SizedBox(height: isVerySmall ? 12 : 16),
            Text(
              'Sin imagen asociada',
              style: TextStyle(
                fontSize: isVerySmall ? 14 : 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextPrimary(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'La imagen se mostrará aquí una vez agregada',
              style: TextStyle(
                fontSize: isVerySmall ? 12 : 13,
                color: AppTheme.getTextSecondary(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
