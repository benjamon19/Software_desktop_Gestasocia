import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/historial_clinico.dart';

class ExportService {
  /// Exporta un historial clínico a PDF
  static Future<bool> exportHistorialToPDF(
    HistorialClinico historial,
    String filePath,
  ) async {
    try {
      final pdf = pw.Document();

      // Logo (opcional, si no existe, omitimos)
      Uint8List? logoBytes;
      try {
        final ByteData logoData = await rootBundle.load('assets/images/gestasocia_logo.png');
        logoBytes = logoData.buffer.asUint8List();
      } catch (e) {
        if (kDebugMode) print('Logo no encontrado: $e');
      }

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.letter,
          margin: const pw.EdgeInsets.all(30),
          build: (context) => [
            // --- Encabezado ---
            if (logoBytes != null)
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Image(pw.MemoryImage(logoBytes), width: 80, height: 80),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Historial Clínico',
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue,
                        ),
                      ),
                      pw.Text(
                        'Generado el: ${DateTime.now().toLocal().toString().split(' ')[0]}',
                        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                      ),
                    ],
                  ),
                ],
              )
            else
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Container(),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Historial Clínico',
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue,
                        ),
                      ),
                      pw.Text(
                        'Generado el: ${DateTime.now().toLocal().toString().split(' ')[0]}',
                        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                      ),
                    ],
                  ),
                ],
              ),

            pw.SizedBox(height: 25),
            pw.Divider(thickness: 1, color: PdfColors.grey400),
            pw.SizedBox(height: 20),

            // --- Datos del Paciente ---
            _buildSection('Datos del Paciente', [
              _buildRow('ID Paciente', historial.pacienteId),
              _buildRow('Tipo de Paciente', historial.pacienteTipo == 'asociado' ? 'Asociado' : 'Carga Familiar'),
              _buildRow('Odontólogo', historial.odontologo),
            ]),

            pw.SizedBox(height: 20),

            // --- Consulta ---
            _buildSection('Consulta', [
              _buildRow('Tipo de Consulta', historial.tipoConsultaFormateado),
              _buildRow('Fecha', historial.fechaFormateada),
              _buildRow('Hora', historial.hora),
              _buildRow('Motivo Principal', historial.motivoPrincipal),
            ]),

            // --- Diagnóstico y Tratamiento (si existen) ---
            if (historial.diagnostico != null && historial.diagnostico!.isNotEmpty)
              ...[
                pw.SizedBox(height: 20),
                _buildSection('Diagnóstico', [
                  pw.Paragraph(
                    text: historial.diagnostico!,
                    style: const pw.TextStyle(fontSize: 11, color: PdfColors.black),
                  ),
                ]),
              ],

            if (historial.tratamientoRealizado != null && historial.tratamientoRealizado!.isNotEmpty)
              ...[
                pw.SizedBox(height: 20),
                _buildSection('Tratamiento Realizado', [
                  pw.Paragraph(
                    text: historial.tratamientoRealizado!,
                    style: const pw.TextStyle(fontSize: 11, color: PdfColors.black),
                  ),
                ]),
              ],

            if (historial.dienteTratado != null && historial.dienteTratado!.isNotEmpty)
              _buildRow('Diente Tratado', historial.dienteTratado!),

            // --- Observaciones del Odontólogo ---
            if (historial.observacionesOdontologo != null && historial.observacionesOdontologo!.isNotEmpty)
              ...[
                pw.SizedBox(height: 20),
                _buildSection('Observaciones del Odontólogo', [
                  pw.Paragraph(
                    text: historial.observacionesOdontologo!,
                    style: const pw.TextStyle(fontSize: 11, color: PdfColors.black),
                  ),
                ]),
              ],

            // --- Antecedentes Médicos ---
            if (historial.tieneAlergias || historial.tomaMedicamentos)
              ...[
                pw.SizedBox(height: 20),
                _buildSection('Antecedentes Médicos', [
                  if (historial.tieneAlergias)
                    _buildRow('Alergias', historial.alergias!),
                  if (historial.tomaMedicamentos)
                    _buildRow('Medicamentos Actuales', historial.medicamentosActuales!),
                ]),
              ],

            // --- Seguimiento ---
            ...[
              pw.SizedBox(height: 20),
              _buildSection('Seguimiento', [
                _buildRow('Próxima Cita', historial.proximaCitaFormateada),
                _buildRow('Estado', historial.estadoFormateado),
                if (historial.costoTratamiento != null)
                  _buildRow('Costo del Tratamiento', '\$${historial.costoTratamiento!.toStringAsFixed(2)}'),
              ]),
            ],
          ],
        ),
      );

      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      return true;
    } catch (e) {
      if (kDebugMode) print('Error al generar PDF del historial clínico: $e');
      return false;
    }
  }

  // ========== HELPERS ==========
  static pw.Widget _buildSection(String title, List<pw.Widget> children) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 160,
            child: pw.Text(
              '$label:',
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey800,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: const pw.TextStyle(color: PdfColors.black, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}