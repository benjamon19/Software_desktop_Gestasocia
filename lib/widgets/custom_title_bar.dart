import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';
import '../controllers/theme_controller.dart';
import '../utils/app_theme.dart';

class CustomTitleBar extends StatelessWidget {
  const CustomTitleBar({super.key});

  bool get _isDesktop {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  @override
  Widget build(BuildContext context) {
    if (!_isDesktop) return const SizedBox.shrink();

    final ThemeController themeController = Get.find<ThemeController>();
    
    return Obx(() {
      final isDark = themeController.themeMode == ThemeMode.dark ||
          (themeController.themeMode == ThemeMode.system &&
              MediaQuery.of(context).platformBrightness == Brightness.dark);
      
      // Usar colores exactos de tu AppTheme
      final bgColor = isDark 
          ? AppTheme.darkSurfaceColor  // Negro/gris oscuro en modo oscuro
          : Colors.white;               // Blanco en modo claro
      final fgColor = isDark 
          ? AppTheme.darkTextPrimary 
          : AppTheme.textPrimary;

      return Container(
        height: 32,
        color: bgColor,
        child: Row(
          children: [
            // Área arrastrable (toda la barra)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanStart: (_) => windowManager.startDragging(),
                onDoubleTap: () async {
                  bool isMaximized = await windowManager.isMaximized();
                  if (isMaximized) {
                    windowManager.unmaximize();
                  } else {
                    windowManager.maximize();
                  }
                },
                child: Container(), // Espacio vacío arrastrable
              ),
            ),

            // Botones de control de ventana
            _WindowButton(
              icon: Icons.remove,
              onPressed: () => windowManager.minimize(),
              color: fgColor,
              hoverColor: isDark 
                  ? Colors.white.withValues(alpha: 0.1) 
                  : Colors.black.withValues(alpha: 0.05),
            ),
            _WindowButton(
              icon: Icons.crop_square,
              onPressed: () async {
                bool isMaximized = await windowManager.isMaximized();
                if (isMaximized) {
                  windowManager.unmaximize();
                } else {
                  windowManager.maximize();
                }
              },
              color: fgColor,
              hoverColor: isDark 
                  ? Colors.white.withValues(alpha: 0.1) 
                  : Colors.black.withValues(alpha: 0.05),
            ),
            _WindowButton(
              icon: Icons.close,
              onPressed: () => windowManager.close(),
              color: fgColor,
              hoverColor: AppTheme.errorColor,
              isCloseButton: true,
            ),
          ],
        ),
      );
    });
  }
}

class _WindowButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;
  final Color hoverColor;
  final bool isCloseButton;

  const _WindowButton({
    required this.icon,
    required this.onPressed,
    required this.color,
    required this.hoverColor,
    this.isCloseButton = false,
  });

  @override
  State<_WindowButton> createState() => _WindowButtonState();
}

class _WindowButtonState extends State<_WindowButton> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovering = true),
      onExit: (_) => setState(() => isHovering = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Container(
          width: 46,
          height: 32,
          decoration: BoxDecoration(
            color: isHovering ? widget.hoverColor : Colors.transparent,
          ),
          child: Icon(
            widget.icon,
            size: 16,
            color: isHovering && widget.isCloseButton 
                ? Colors.white 
                : widget.color,
          ),
        ),
      ),
    );
  }
}