import 'package:cloud_firestore/cloud_firestore.dart';

class Usuario {
  String? id;
  String nombre;
  String apellido;
  String email;
  String telefono;
  String rut;
  String? photoUrl; // NUEVO: URL de la foto de perfil
  DateTime fechaCreacion;
  bool isActive;

  Usuario({
    this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.telefono,
    required this.rut,
    this.photoUrl, // NUEVO
    required this.fechaCreacion,
    this.isActive = true,
  });

  // Getters útiles
  String get nombreCompleto => '$nombre $apellido';
  
  String get rutFormateado {
    if (rut.length < 2) return rut;
    String cuerpo = rut.substring(0, rut.length - 1);
    String dv = rut.substring(rut.length - 1);
    
    // Formatear cuerpo con puntos
    String cuerpoFormateado = '';
    for (int i = cuerpo.length - 1; i >= 0; i--) {
      if ((cuerpo.length - i) % 3 == 1 && i != cuerpo.length - 1) {
        cuerpoFormateado = '.$cuerpoFormateado';
      }
      cuerpoFormateado = '${cuerpo[i]}$cuerpoFormateado';
    }
    
    return '$cuerpoFormateado-$dv';
  }

  // Validación de RUT chileno
  static bool validarRUT(String rut) {
    try {
      // Limpiar RUT (quitar puntos y guión)
      String rutLimpio = rut.replaceAll(RegExp(r'[^0-9kK]'), '');
      
      if (rutLimpio.length < 2) return false;
      
      String cuerpo = rutLimpio.substring(0, rutLimpio.length - 1);
      String dv = rutLimpio.substring(rutLimpio.length - 1).toUpperCase();
      
      // Validar que el cuerpo sean solo números
      if (!RegExp(r'^[0-9]+$').hasMatch(cuerpo)) return false;
      
      // Calcular dígito verificador
      int suma = 0;
      int multiplicador = 2;
      
      for (int i = cuerpo.length - 1; i >= 0; i--) {
        suma += int.parse(cuerpo[i]) * multiplicador;
        multiplicador = multiplicador == 7 ? 2 : multiplicador + 1;
      }
      
      int resto = suma % 11;
      String dvCalculado = resto == 0 ? '0' : resto == 1 ? 'K' : (11 - resto).toString();
      
      return dv == dvCalculado;
    } catch (e) {
      return false;
    }
  }

  // Convertir a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'telefono': telefono,
      'rut': rut,
      'photoUrl': photoUrl, // NUEVO
      'fechaCreacion': fechaCreacion,
      'isActive': isActive,
    };
  }

  // Crear desde Map de Firestore
  factory Usuario.fromMap(Map<String, dynamic> map, String id) {
    return Usuario(
      id: id,
      nombre: map['nombre'] ?? '',
      apellido: map['apellido'] ?? '',
      email: map['email'] ?? '',
      telefono: map['telefono'] ?? '',
      rut: map['rut'] ?? '',
      photoUrl: map['photoUrl'], // NUEVO
      fechaCreacion: _parseDateTime(map['fechaCreacion']),
      isActive: map['isActive'] ?? true,
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
      // Para Timestamp de Firestore
      return fecha.toDate();
    } else {
      return DateTime.now();
    }
  }

  // Crear copia con cambios
  Usuario copyWith({
    String? id,
    String? nombre,
    String? apellido,
    String? email,
    String? telefono,
    String? rut,
    String? photoUrl, // NUEVO
    DateTime? fechaCreacion,
    bool? isActive,
  }) {
    return Usuario(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      rut: rut ?? this.rut,
      photoUrl: photoUrl ?? this.photoUrl, // NUEVO
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'Usuario{id: $id, nombreCompleto: $nombreCompleto, email: $email, rut: $rutFormateado}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Usuario && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}