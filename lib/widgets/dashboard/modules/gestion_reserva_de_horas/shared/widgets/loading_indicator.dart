import 'package:flutter/material.dart';
import '../../../../../../utils/app_theme.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;

  const LoadingIndicator({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            message ?? 'Cargando...',
            style: TextStyle(
              color: AppTheme.getTextSecondary(context),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}