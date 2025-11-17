import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class InteractiveLink extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const InteractiveLink({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  State<InteractiveLink> createState() => _InteractiveLinkState();
}

class _InteractiveLinkState extends State<InteractiveLink> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: Text(
            widget.text,
            style: TextStyle(
              color: isHovered
                  ? const Color.fromARGB(255, 45, 99, 143)
                  : AppTheme.primaryColor.withValues(alpha: 0.8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
