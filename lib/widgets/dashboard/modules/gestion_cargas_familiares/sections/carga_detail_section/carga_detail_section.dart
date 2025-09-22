import 'package:flutter/material.dart';
import '../../../../../../utils/app_theme.dart';
import '../../../../../../models/carga_familiar.dart';
import 'components/carga_header.dart';
import 'components/personal_info_card.dart';
import 'components/medical_info_card.dart';
import 'components/family_info_card.dart';

class CargaDetailSection extends StatelessWidget {
  final Map<String, dynamic> carga;
  final VoidCallback onEdit;

  const CargaDetailSection({super.key, required this.carga, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    // Convertir el Map a CargaFamiliar
    final cargaFamiliar = CargaFamiliar.fromMap(carga, carga['id'] ?? '');
    
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CargaHeader(carga: carga, onEdit: onEdit),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  PersonalInfoCard(carga: cargaFamiliar),
                  const SizedBox(height: 20),
                  MedicalInfoCard(carga: carga),
                  const SizedBox(height: 20),
                  FamilyInfoCard(carga: carga),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}