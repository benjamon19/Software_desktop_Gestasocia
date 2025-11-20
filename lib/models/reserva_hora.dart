import 'package:cloud_firestore/cloud_firestore.dart';

class ReservaHora {
  String? id;
  String pacienteId;
  String pacienteNombre;
  String pacienteTipo; // 'asociado' o 'carga'
  String pacienteRut;
  String odontologo;
  DateTime fecha;
  String hora; // Formato HH:mm
  String motivo;
  String estado; // 'pendiente', 'confirmada', 'cancelada', 'realizada'
  String? observaciones;
  DateTime fechaCreacion;

  ReservaHora({
    this.id,
    required this.pacienteId,
    required this.pacienteNombre,
    required this.pacienteTipo,
    required this.pacienteRut,
    required this.odontologo,
    required this.fecha,
    required this.hora,
    required this.motivo,
    this.estado = 'pendiente',
    this.observaciones,
    required this.fechaCreacion,
  });

  // Getter útil para mostrar fecha en formato String
  String get fechaFormateada {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }

  // Convertir a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'pacienteId': pacienteId,
      'pacienteNombre': pacienteNombre,
      'pacienteTipo': pacienteTipo,
      'pacienteRut': pacienteRut,
      'odontologo': odontologo,
      'fecha': Timestamp.fromDate(fecha),
      'hora': hora,
      'motivo': motivo,
      'estado': estado,
      'observaciones': observaciones,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
    };
  }

  // Crear desde Firestore
  factory ReservaHora.fromMap(Map<String, dynamic> map, String id) {
    return ReservaHora(
      id: id,
      pacienteId: map['pacienteId'] ?? '',
      pacienteNombre: map['pacienteNombre'] ?? 'Desconocido',
      pacienteTipo: map['pacienteTipo'] ?? 'asociado',
      pacienteRut: map['pacienteRut'] ?? '',
      odontologo: map['odontologo'] ?? '',
      fecha: _parseDateTime(map['fecha']),
      hora: map['hora'] ?? '',
      motivo: map['motivo'] ?? '',
      estado: map['estado'] ?? 'pendiente',
      observaciones: map['observaciones'],
      fechaCreacion: _parseDateTime(map['fechaCreacion']),
    );
  }

  // Manejo correcto de DateTime / Timestamp
  static DateTime _parseDateTime(dynamic fecha) {
    if (fecha == null) return DateTime.now();
    if (fecha is DateTime) return fecha;
    if (fecha is Timestamp) return fecha.toDate();
    return DateTime.now();
  }

  // CopyWith para actualizaciones inmutables
  ReservaHora copyWith({
    String? id,
    String? pacienteId,
    String? pacienteNombre,
    String? pacienteTipo,
    String? pacienteRut,
    String? odontologo,
    DateTime? fecha,
    String? hora,
    String? motivo,
    String? estado,
    String? observaciones,
    DateTime? fechaCreacion,
  }) {
    return ReservaHora(
      id: id ?? this.id,
      pacienteId: pacienteId ?? this.pacienteId,
      pacienteNombre: pacienteNombre ?? this.pacienteNombre,
      pacienteTipo: pacienteTipo ?? this.pacienteTipo,
      pacienteRut: pacienteRut ?? this.pacienteRut,
      odontologo: odontologo ?? this.odontologo,
      fecha: fecha ?? this.fecha,
      hora: hora ?? this.hora,
      motivo: motivo ?? this.motivo,
      estado: estado ?? this.estado,
      observaciones: observaciones ?? this.observaciones,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }
}