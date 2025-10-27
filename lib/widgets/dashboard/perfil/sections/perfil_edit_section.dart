import 'package:flutter/material.dart';
import 'perfil_photo_section.dart';
import 'perfil_password_section.dart';

class PerfilEditSectionSimple extends StatelessWidget {
  const PerfilEditSectionSimple({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bool isShortScreen = screenHeight < 700;
    final bool isVeryShortScreen = screenHeight < 600;

    // Espaciado adaptativo entre cards
    double cardSpacing = isVeryShortScreen ? 12 : (isShortScreen ? 16 : 20);

    return SingleChildScrollView(
      child: Column(
        children: [
          // Sección de foto de perfil
          PerfilPhotoSection(),
          
          SizedBox(height: cardSpacing),
          
          // Sección de cambio de contraseña (con confirmación)
          PerfilPasswordSection(),
        ],
      ),
    );
  }
}