import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class TermsAndConditionsDialog {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.getSurfaceColor(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Términos y Condiciones de Uso',
          style: TextStyle(
            color: AppTheme.getTextPrimary(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Última actualización: 16 de noviembre de 2025',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 16),

                _section(
                  '1. Aceptación de los términos',
                  'Al utilizar GestAsocia, aceptas estos Términos y Condiciones de Uso. '
                  'Esta aplicación es un proyecto académico y no representa un servicio comercial.'
                ),

                _section(
                  '2. Propósito de la aplicación',
                  'GestAsocia está diseñada para apoyar la gestión de asociados, cargas familiares, '
                  'historial clínico y reserva de horas, además de un dashboard de métricas internas. '
                  'La app puede ser utilizada únicamente por odontólogos y personal administrativo autorizado.'
                ),

                _section(
                  '3. Datos recopilados',
                  'La aplicación registra datos de usuarios del sistema, asociados y cargas, incluyendo información '
                  'personal básica, información clínica, actividades y datos operativos. '
                  'No se utilizan datos reales fuera del contexto académico.'
                ),

                _section(
                  '3.1 Datos de usuarios del sistema',
                  'Se almacena: id, nombre, apellido, email, teléfono, rut, rol, código único, photoUrl (opcional), '
                  'fecha de creación e indicador de actividad.'
                ),

                _section(
                  '3.2 Datos de asociados y cargas',
                  'Se almacena: id, nombre, apellido, rut, fecha de nacimiento, estado civil, email, teléfono, dirección, '
                  'plan, fecha de creación, fecha de ingreso, estado, código de barras (opcional), sap (opcional) '
                  'y última actividad.'
                ),

                _section(
                  '3.3 Datos del historial clínico',
                  'Incluye información de consultas, odontólogos, fechas, diagnósticos, tratamientos, alergias, '
                  'medicamentos, próximas citas, imágenes clínicas, estado del procedimiento y registro de cambios.'
                ),

                _section(
                  '4. Uso autorizado',
                  'El acceso está limitado a personal autorizado. Las credenciales son personales e intransferibles.'
                ),

                _section(
                  '5. Protección de datos',
                  'La información es almacenada en Firebase (Auth, Firestore y Storage). '
                  'Se aplican reglas de seguridad para proteger el acceso y evitar filtraciones. '
                  'Los datos no se comparten con terceros.'
                ),

                _section(
                  '6. Registro de actividad',
                  'El sistema mantiene historial de cambios y acciones relevantes realizadas por los usuarios.'
                ),

                _section(
                  '7. Eliminación de datos',
                  'Los usuarios pueden solicitar la eliminación de sus datos o información asociada. '
                  'La eliminación se realizará respetando las dependencias internas del sistema.'
                ),

                _section(
                  '8. Respaldo de información',
                  'La aplicación utiliza los mecanismos de respaldo proporcionados por Firebase. '
                  'No somos responsables por pérdidas o errores ocasionados por acciones del usuario.'
                ),

                _section(
                  '9. Responsabilidad',
                  'No somos responsables por mal uso de credenciales, eliminación accidental de datos por parte del usuario, '
                  'errores de ingreso o manipulación incorrecta de la información.'
                ),

                _section(
                  '10. Modificaciones',
                  'Estos términos pueden actualizarse en cualquier momento acorde al desarrollo del proyecto.'
                ),

                _section(
                  '11. Soporte',
                  'El soporte se gestiona desde la aplicación en Configuración > Sistema, donde se puede abrir un ticket '
                  'o contactar directamente si es necesario. No existe disponibilidad 24/7.'
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cerrar',
              style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _section(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 4),
        Text(content, style: const TextStyle(fontSize: 13, height: 1.4)),
        const SizedBox(height: 12),
      ],
    );
  }
}
