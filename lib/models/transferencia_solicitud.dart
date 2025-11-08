import 'package:cloud_firestore/cloud_firestore.dart';

class TransferenciaSolicitud {
  String? id;
  String cargaId;
  String cargaNombre;
  String cargaRut;
  String asociadoOrigenId;
  String asociadoOrigenNombre;
  String asociadoDestinoId;
  String asociadoDestinoNombre;
  DateTime fechaSolicitud;
  String estado; // 'pendiente', 'aprobada', 'rechazada'
  String? motivoRechazo;
  DateTime? fechaRespuesta;

  TransferenciaSolicitud({
    this.id,
    required this.cargaId,
    required this.cargaNombre,
    required this.cargaRut,
    required this.asociadoOrigenId,
    required this.asociadoOrigenNombre,
    required this.asociadoDestinoId,
    required this.asociadoDestinoNombre,
    required this.fechaSolicitud,
    this.estado = 'pendiente',
    this.motivoRechazo,
    this.fechaRespuesta,
  });

  Map<String, dynamic> toMap() {
    return {
      'cargaId': cargaId,
      'cargaNombre': cargaNombre,
      'cargaRut': cargaRut,
      'asociadoOrigenId': asociadoOrigenId,
      'asociadoOrigenNombre': asociadoOrigenNombre,
      'asociadoDestinoId': asociadoDestinoId,
      'asociadoDestinoNombre': asociadoDestinoNombre,
      'fechaSolicitud': fechaSolicitud,
      'estado': estado,
      'motivoRechazo': motivoRechazo,
      'fechaRespuesta': fechaRespuesta,
    };
  }

  factory TransferenciaSolicitud.fromMap(Map<String, dynamic> map, String id) {
    return TransferenciaSolicitud(
      id: id,
      cargaId: map['cargaId'] ?? '',
      cargaNombre: map['cargaNombre'] ?? '',
      cargaRut: map['cargaRut'] ?? '',
      asociadoOrigenId: map['asociadoOrigenId'] ?? '',
      asociadoOrigenNombre: map['asociadoOrigenNombre'] ?? '',
      asociadoDestinoId: map['asociadoDestinoId'] ?? '',
      asociadoDestinoNombre: map['asociadoDestinoNombre'] ?? '',
      fechaSolicitud: _parseDateTime(map['fechaSolicitud']),
      estado: map['estado'] ?? 'pendiente',
      motivoRechazo: map['motivoRechazo'],
      fechaRespuesta: map['fechaRespuesta'] != null ? _parseDateTime(map['fechaRespuesta']) : null,
    );
  }

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

  TransferenciaSolicitud copyWith({
    String? id,
    String? cargaId,
    String? cargaNombre,
    String? cargaRut,
    String? asociadoOrigenId,
    String? asociadoOrigenNombre,
    String? asociadoDestinoId,
    String? asociadoDestinoNombre,
    DateTime? fechaSolicitud,
    String? estado,
    String? motivoRechazo,
    DateTime? fechaRespuesta,
  }) {
    return TransferenciaSolicitud(
      id: id ?? this.id,
      cargaId: cargaId ?? this.cargaId,
      cargaNombre: cargaNombre ?? this.cargaNombre,
      cargaRut: cargaRut ?? this.cargaRut,
      asociadoOrigenId: asociadoOrigenId ?? this.asociadoOrigenId,
      asociadoOrigenNombre: asociadoOrigenNombre ?? this.asociadoOrigenNombre,
      asociadoDestinoId: asociadoDestinoId ?? this.asociadoDestinoId,
      asociadoDestinoNombre: asociadoDestinoNombre ?? this.asociadoDestinoNombre,
      fechaSolicitud: fechaSolicitud ?? this.fechaSolicitud,
      estado: estado ?? this.estado,
      motivoRechazo: motivoRechazo ?? this.motivoRechazo,
      fechaRespuesta: fechaRespuesta ?? this.fechaRespuesta,
    );
  }

  @override
  String toString() {
    return 'TransferenciaSolicitud{id: $id, carga: $cargaNombre, estado: $estado}';
  }
}