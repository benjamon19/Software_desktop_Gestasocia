import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'custom_title_bar.dart';

class DesktopWrapper extends StatelessWidget {
  final Widget child;

  const DesktopWrapper({
    super.key,
    required this.child,
  });

  bool get _isDesktop {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  @override
  Widget build(BuildContext context) {
    if (!_isDesktop) {
      return child;
    }

    return Column(
      children: [
        const CustomTitleBar(),
        Expanded(child: child),
      ],
    );
  }
}