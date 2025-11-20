import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/reserva_hora.dart'; // Asegúrate que esta ruta sea correcta

class ReservaHorasController extends GetxController {
  // === ESTADO REACTIVO ===
  RxList<ReservaHora> reservas = <ReservaHora>[].obs;
  RxBool isLoading = false.obs;
  Rx<DateTime> selectedDate = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    loadReservas();
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

  // === FILTRO POR FECHA (Helper) ===
  List<ReservaHora> getReservasPorFecha(DateTime fecha) {
    return reservas.where((r) =>
        r.fecha.year == fecha.year &&
        r.fecha.month == fecha.month &&
        r.fecha.day == fecha.day).toList();
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