import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/reserva_hora.dart';

class ReservaHorasController extends GetxController {
  // === ESTADO REACTIVO ===
  RxList<ReservaHora> reservas = <ReservaHora>[].obs;
  RxBool isLoading = false.obs;
  Rx<DateTime> selectedDate = DateTime.now().obs;

  // === CONFIGURACIÓN DE HORARIO ===
  // Esto asegura que nadie agende a las 3 AM
  static const int horaApertura = 8; // 8:00 AM
  static const int horaCierre = 20;  // 20:00 PM

  @override
  void onInit() {
    super.onInit();
    loadReservas();
  }

  // === VALIDACIÓN DE DISPONIBILIDAD (NUEVO) ===
  /// Retorna un String con el error si no es válido, o null si está disponible.
  String? validarReserva(String odontologoNombre, DateTime fecha, String horaStr) {
    
    // 1. Validar Horario de Clínica (ej: 08:00 - 20:00)
    final parts = horaStr.split(':');
    final horaInt = int.parse(parts[0]);
    
    if (horaInt < horaApertura || horaInt >= horaCierre) {
      return 'La clínica está cerrada a esa hora. Horario: $horaApertura:00 - $horaCierre:00';
    }

    // 2. Validar Disponibilidad del Odontólogo
    // Buscamos si ESTE odontólogo ya tiene algo ese día a esa hora.
    final conflicto = reservas.firstWhereOrNull((reserva) {
      // Ignoramos citas canceladas
      if (reserva.estado.toLowerCase() == 'cancelada') return false;

      // Si es OTRO odontólogo, no hay conflicto (pueden trabajar en paralelo)
      if (reserva.odontologo != odontologoNombre) return false;

      // Verificar misma fecha (año, mes, día)
      if (reserva.fecha.year != fecha.year || 
          reserva.fecha.month != fecha.month || 
          reserva.fecha.day != fecha.day) {
        return false;
      }

      // Verificar misma hora
      return reserva.hora == horaStr;
    });

    if (conflicto != null) {
      return 'El $odontologoNombre ya tiene una cita agendada a las $horaStr.';
    }

    // Si pasa todas las pruebas, retornamos null (todo OK)
    return null;
  }

  // === CARGAR RESERVAS ===
  Future<void> loadReservas() async {
    try {
      isLoading.value = true;
      final snapshot = await FirebaseFirestore.instance
          .collection('reservas_horas')
          .orderBy('fecha')
          .get();

      reservas.assignAll(
        snapshot.docs.map((d) => ReservaHora.fromMap(d.data(), d.id)).toList(),
      );
    } catch (e) {
      debugPrint('Error cargando reservas: $e');
      _showSnackbar('Error', 'No se pudieron cargar las reservas', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  // === CREAR RESERVA ===
  Future<bool> createReserva(ReservaHora reserva) async {
    try {
      isLoading.value = true;
      final docRef = await FirebaseFirestore.instance
          .collection('reservas_horas')
          .add(reserva.toMap());

      reservas.add(reserva.copyWith(id: docRef.id));
      _showSnackbar('Éxito', 'Reserva agendada correctamente');
      return true;
    } catch (e) {
      debugPrint('Error creando reserva: $e');
      _showSnackbar('Error', 'No se pudo crear la reserva', isError: true);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // === ACTUALIZAR RESERVA ===
  Future<bool> updateReserva(ReservaHora reservaActualizada) async {
    try {
      isLoading.value = true;
      if (reservaActualizada.id == null) throw Exception('ID de reserva no válido');

      await FirebaseFirestore.instance
          .collection('reservas_horas')
          .doc(reservaActualizada.id)
          .update(reservaActualizada.toMap());

      final index = reservas.indexWhere((r) => r.id == reservaActualizada.id);
      if (index != -1) {
        reservas[index] = reservaActualizada;
        reservas.refresh();
      }

      _showSnackbar('Éxito', 'Reserva actualizada');
      return true;
    } catch (e) {
      debugPrint('Error actualizando reserva: $e');
      _showSnackbar('Error', 'No se pudo actualizar la reserva', isError: true);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // === ELIMINAR RESERVA ===
  Future<bool> deleteReserva(String reservaId) async {
    try {
      isLoading.value = true;
      await FirebaseFirestore.instance
          .collection('reservas_horas')
          .doc(reservaId)
          .delete();

      reservas.removeWhere((r) => r.id == reservaId);
      reservas.refresh();

      _showSnackbar('Éxito', 'Reserva eliminada');
      return true;
    } catch (e) {
      debugPrint('Error eliminando reserva: $e');
      _showSnackbar('Error', 'No se pudo eliminar la reserva', isError: true);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // === UI HELPERS ===
  void _showSnackbar(String title, String message, {bool isError = false}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError ? Colors.red.withValues(alpha: 0.9) : const Color(0xFF10B981).withValues(alpha: 0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(12),
      borderRadius: 8,
    );
  }
}