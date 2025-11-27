import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class CodigoInputDialog {
  static void show(
    BuildContext context, {
    required Function(String) onConfirm,
    required VoidCallback onCancel,
  }) {
    final codigoController = TextEditingController();
    final focusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNode.requestFocus();
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.getSurfaceColor(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        icon: const Icon(
          Icons.vpn_key_rounded,
          color: Colors.blue,
          size: 48,
        ),
        title: Text(
          'Código Único de Acceso',
          style: TextStyle(
            color: AppTheme.getTextPrimary(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Ingresa el código único que guardaste al registrarte.',
              style: TextStyle(
                color: AppTheme.getTextPrimary(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 70,
              child: TextField(
                controller: codigoController,
                focusNode: focusNode,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 6,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  labelText: 'Código único',
                  labelStyle:
                      TextStyle(color: AppTheme.getTextSecondary(context)),
                  prefixIcon: const Icon(Icons.lock_outline),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Colors.grey,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Colors.blue,
                      width: 1.5,
                    ),
                  ),
                ),
                onSubmitted: (value) {
                  final codigo = codigoController.text.trim();
                  Navigator.of(context).pop();
                  onConfirm(codigo);
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: AppTheme.getTextSecondary(context),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              final codigo = codigoController.text.trim();
              Navigator.of(context).pop();
              onConfirm(codigo);
            },
            child: const Text(
              'Aceptar',
              style: TextStyle(
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
