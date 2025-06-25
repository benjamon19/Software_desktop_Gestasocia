import 'package:flutter/material.dart';
import '../../../shared/widgets/section_title.dart';
import '../../../shared/widgets/action_button.dart';
import '../../../shared/dialogs/export_options_dialog.dart';
import '../../../shared/dialogs/backup_options_dialog.dart';

class AdvancedOptionsActions extends StatelessWidget {
  const AdvancedOptionsActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Opciones Avanzadas'),
        const SizedBox(height: 12),
        
        ActionButton(
          icon: Icons.download,
          title: 'Exportar Datos',
          subtitle: 'Descargar información en PDF',
          color: const Color(0xFF059669),
          onPressed: () => _showExportOptions(context),
        ),
        
        const SizedBox(height: 8),
        
        ActionButton(
          icon: Icons.backup,
          title: 'Backup de Datos',
          subtitle: 'Crear copia de seguridad',
          color: const Color(0xFF0EA5E9),
          onPressed: () => _showBackupOptions(context),
        ),
      ],
    );
  }

  void _showExportOptions(BuildContext context) {
    ExportOptionsDialog.show(context);
  }

  void _showBackupOptions(BuildContext context) {
    BackupOptionsDialog.show(context);
  }
}