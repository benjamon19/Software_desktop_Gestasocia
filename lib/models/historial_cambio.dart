import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HistorialCambio {
  String? id;
  String asociadoId;
  String usuarioId;
  String usuarioNombre;
  String tipoAccion;
  String descripcion;
  Map<String, dynamic>? valoresAnteriores;
  Map<String, dynamic>? valoresNuevos;
  Map<String, dynamic>? datosAdicionales;
  DateTime fechaHora;

  HistorialCambio({
    this.id,
    required this.asociadoId,
    required this.usuarioId,
    required this.usuarioNombre,
    required this.tipoAccion,
    required this.descripcion,
    this.valoresAnteriores,
    this.valoresNuevos,
    this.datosAdicionales,
    required this.fechaHora,
  });

  // Convertir a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'asociadoId': asociadoId,
      'usuarioId': usuarioId,
      'usuarioNombre': usuarioNombre,
      'tipoAccion': tipoAccion,
      'descripcion': descripcion,
      'valoresAnteriores': valoresAnteriores,
      'valoresNuevos': valoresNuevos,
      'datosAdicionales': datosAdicionales,
      'fechaHora': fechaHora,
    };
  }

  // Crear desde Map de Firestore
  factory HistorialCambio.fromMap(Map<String, dynamic> map, String id) {
    return HistorialCambio(
      id: id,
      asociadoId: map['asociadoId'] ?? '',
      usuarioId: map['usuarioId'] ?? '',
      usuarioNombre: map['usuarioNombre'] ?? 'Usuario Desconocido',
      tipoAccion: map['tipoAccion'] ?? '',
      descripcion: map['descripcion'] ?? '',
      valoresAnteriores: map['valoresAnteriores'] != null 
          ? Map<String, dynamic>.from(map['valoresAnteriores']) 
          : null,
      valoresNuevos: map['valoresNuevos'] != null 
          ? Map<String, dynamic>.from(map['valoresNuevos']) 
          : null,
      datosAdicionales: map['datosAdicionales'] != null 
          ? Map<String, dynamic>.from(map['datosAdicionales']) 
          : null,
      fechaHora: _parseDateTime(map['fechaHora']),
    );
  }

  // Helper para manejar diferentes tipos de fecha
  static DateTime _parseDateTime(dynamic fecha) {
    if (fecha == null) return DateTime.now();
    
    if (fecha is DateTime) {
      return fecha;
    } else if (fecha is String) {
      try {
        return DateTime.parse(fecha);
      } catch (e) {
        return DateTime.now();
      }
    } else if (fecha is Timestamp) {
      return fecha.toDate();
    } else {
      return DateTime.now();
    }
  }

  String get fechaFormateada {
    return '${fechaHora.day.toString().padLeft(2, '0')}/'
           '${fechaHora.month.toString().padLeft(2, '0')}/'
           '${fechaHora.year} - '
           '${fechaHora.hour.toString().padLeft(2, '0')}:'
           '${fechaHora.minute.toString().padLeft(2, '0')}';
  }

  // Obtener lista de campos que cambiaron
  List<String> get camposModificados {
    if (valoresAnteriores == null || valoresNuevos == null) {
      return [];
    }

    List<String> campos = [];
    valoresNuevos!.forEach((key, value) {
      if (valoresAnteriores!.containsKey(key)) {
        if (valoresAnteriores![key] != value) {
          campos.add(key);
        }
      }
    });
    
    return campos;
  }

  static String getNombreCampo(String campo) {
    const Map<String, String> nombres = {
      'nombre': 'Nombre',
      'apellido': 'Apellido',
      'email': 'Correo Electrónico',
      'telefono': 'Teléfono',
      'direccion': 'Dirección',
      'estadoCivil': 'Estado Civil',
      'plan': 'Plan de Membresía',
      'fechaNacimiento': 'Fecha de Nacimiento',
      'codigoBarras': 'Código de Barras',
      'sap': 'Código SAP',
      'rut': 'RUT',
      'parentesco': 'Parentesco',
    };
    
    return nombres[campo] ?? campo;
  }

  // Icono según tipo de acción
  static IconData getIconoTipoAccion(String tipoAccion) {
    switch (tipoAccion) {
      case 'creacion':
        return Icons.add_circle;
      case 'edicion':
        return Icons.edit;
      case 'agregoCarga':
        return Icons.person_add;
      case 'eliminoCarga':
        return Icons.person_remove;
      case 'editoCarga':
        return Icons.edit_note;
      case 'generoBarras':
        return Icons.qr_code;
      case 'generoSAP':
        return Icons.tag;
      case 'exportoDatos':
        return Icons.download;
      case 'importoDatos':
        return Icons.upload;
      default:
        return Icons.history;
    }
  }

  // Color según tipo de acción
  static Color getColorTipoAccion(String tipoAccion) {
    switch (tipoAccion) {
      case 'creacion':
        return const Color(0xFF059669);
      case 'edicion':
        return const Color(0xFF3B82F6);
      case 'agregoCarga':
        return const Color(0xFF8B5CF6);
      case 'eliminoCarga':
        return const Color(0xFFEF4444);
      case 'editoCarga':
        return const Color(0xFF06B6D4);
      case 'generoBarras':
        return const Color(0xFFF59E0B);
      case 'generoSAP':
        return const Color(0xFF10B981);
      case 'exportoDatos':
        return const Color(0xFF6366F1);
      case 'importoDatos':
        return const Color(0xFFEC4899);
      default:
        return const Color(0xFF6B7280);
    }
  }

  @override
  String toString() {
    return 'HistorialCambio{id: $id, tipoAccion: $tipoAccion, fecha: $fechaFormateada}';
  }
}