import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:get/get.dart';
import '../models/asociado.dart';
import '../models/carga_familiar.dart';
import '../controllers/historial_controller.dart';

class ExportCargasService {
  /// Exportar carga familiar a PDF
  static Future<bool> exportToPDF(
    Asociado asociado,
    CargaFamiliar carga,
    String filePath,
  ) async {
    try {
      final pdf = pw.Document();

      final ByteData logoData =
          await rootBundle.load('assets/images/gestasocia_logo.png');
      final Uint8List logoBytes = logoData.buffer.asUint8List();
      final logo = pw.MemoryImage(logoBytes);

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.letter,
          margin: const pw.EdgeInsets.all(40),
          build: (context) => [
            // Header con logo
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Image(logo, width: 100, height: 100),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'GestAsocia',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromInt(0xFF10B981), // Verde
                      ),
                    ),
                    pw.Text(
                      'Sistema de Gestión de Asociados',
                      style: const pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 30),
            pw.Divider(thickness: 2),
            pw.SizedBox(height: 20),
            
            pw.Text(
              'Carga Familiar',
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromInt(0xFF10B981),
              ),
            ),
            pw.SizedBox(height: 20),
            
            // Sección Datos Personales de la Carga
            _buildInfoSection('Datos Personales', PdfColor.fromInt(0xFF10B981), [
              _buildInfoRow('Nombre Completo', carga.nombreCompleto),
              _buildInfoRow('RUT', carga.rutFormateado),
              _buildInfoRow('Parentesco', carga.parentesco),
              _buildInfoRow('Fecha de Nacimiento', carga.fechaNacimientoFormateada),
              _buildInfoRow('Edad', '${carga.edad} años'),
              _buildInfoRow('Estado', carga.estado),
            ]),
            
            if (carga.email != null && carga.email!.isNotEmpty || 
                carga.telefono != null && carga.telefono!.isNotEmpty ||
                carga.direccion != null && carga.direccion!.isNotEmpty) ...[
              pw.SizedBox(height: 20),
              _buildInfoSection('Información de Contacto', PdfColor.fromInt(0xFF10B981), [
                if (carga.email != null && carga.email!.isNotEmpty)
                  _buildInfoRow('Email', carga.email!),
                if (carga.telefono != null && carga.telefono!.isNotEmpty)
                  _buildInfoRow('Teléfono', carga.telefono!),
                if (carga.direccion != null && carga.direccion!.isNotEmpty)
                  _buildInfoRow('Dirección', carga.direccion!),
              ]),
            ],
            
            pw.SizedBox(height: 20),
            _buildInfoSection('Información Adicional', PdfColor.fromInt(0xFF10B981), [
              _buildInfoRow('Fecha de Creación', carga.fechaCreacionFormateada),
              if (carga.ultimaActividad != null)
                _buildInfoRow(
                  'Última Actividad', 
                  '${carga.ultimaActividad!.day.toString().padLeft(2, '0')}/'
                  '${carga.ultimaActividad!.month.toString().padLeft(2, '0')}/'
                  '${carga.ultimaActividad!.year}'
                ),
              if (carga.ultimaVisita != null && carga.ultimaVisita!.isNotEmpty)
                _buildInfoRow('Última Visita', carga.ultimaVisita!),
              if (carga.proximaCita != null && carga.proximaCita!.isNotEmpty)
                _buildInfoRow('Próxima Cita', carga.proximaCita!),
              if (carga.codigoBarras != null && carga.codigoBarras!.isNotEmpty)
                _buildInfoRow('Código de Barras', carga.codigoBarras!),
            ]),
            
            if (carga.alertas != null && carga.alertas!.isNotEmpty) ...[
              pw.SizedBox(height: 20),
              _buildInfoSection('Alertas', PdfColor.fromInt(0xFF10B981), [
                for (final alerta in carga.alertas!)
                  _buildInfoRow('Alerta', alerta),
              ]),
            ],
            
            pw.SizedBox(height: 30),
            
            pw.Text(
              'Asociado Titular',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromInt(0xFF10B981),
              ),
            ),
            pw.SizedBox(height: 15),
            _buildInfoSection('Datos del Titular', PdfColor.fromInt(0xFF10B981), [
              _buildInfoRow('Nombre Completo', asociado.nombreCompleto),
              _buildInfoRow('RUT', asociado.rutFormateado),
              _buildInfoRow('Email', asociado.email),
              _buildInfoRow('Teléfono', asociado.telefono),
              _buildInfoRow('Plan', asociado.plan),
              if (asociado.sap != null && asociado.sap!.isNotEmpty)
                _buildInfoRow('Código SAP', asociado.sap!),
              _buildInfoRow('Estado', asociado.estado),
            ]),
          ],
        ),
      );

      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      _registrarExportacion(asociado.id!, 'PDF', filePath, carga.id!);
      return true;
    } catch (e) {
      if (kDebugMode) print('Error al generar PDF: $e');
      return false;
    }
  }

  /// Exportar carga familiar a Excel
  static Future<bool> exportToExcel(
    Asociado asociado,
    CargaFamiliar carga,
    String filePath,
  ) async {
    try {
      var excel = Excel.createExcel();
      Sheet sheet = excel['Sheet1'];
      excel.setDefaultSheet('Sheet1');

      CellStyle headerStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.fromHexString('#10B981'),
        fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      );

      sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue('CARGA FAMILIAR');
      sheet.cell(CellIndex.indexByString('B1')).value = TextCellValue('');
      sheet.cell(CellIndex.indexByString('A1')).cellStyle = headerStyle;
      sheet.cell(CellIndex.indexByString('B1')).cellStyle = headerStyle;

      int row = 2;
      _addExcelRow(sheet, row++, 'Nombre Completo', carga.nombreCompleto);
      _addExcelRow(sheet, row++, 'RUT', carga.rutFormateado);
      _addExcelRow(sheet, row++, 'Parentesco', carga.parentesco);
      _addExcelRow(sheet, row++, 'Fecha de Nacimiento', carga.fechaNacimientoFormateada);
      _addExcelRow(sheet, row++, 'Edad', '${carga.edad} años');
      _addExcelRow(sheet, row++, 'Estado', carga.estado);

      if (carga.email != null && carga.email!.isNotEmpty || 
          carga.telefono != null && carga.telefono!.isNotEmpty) {
        row++;
        _addExcelRow(sheet, row++, 'Email', carga.email ?? '');
        _addExcelRow(sheet, row++, 'Teléfono', carga.telefono ?? '');
        if (carga.direccion != null && carga.direccion!.isNotEmpty) {
          _addExcelRow(sheet, row++, 'Dirección', carga.direccion!);
        }
      }

      row++;
      _addExcelRow(sheet, row++, 'Fecha de Creación', carga.fechaCreacionFormateada);
      if (carga.ultimaActividad != null) {
        _addExcelRow(sheet, row++, 'Última Actividad', 
          '${carga.ultimaActividad!.day.toString().padLeft(2, '0')}/'
          '${carga.ultimaActividad!.month.toString().padLeft(2, '0')}/'
          '${carga.ultimaActividad!.year}'
        );
      }
      if (carga.ultimaVisita != null && carga.ultimaVisita!.isNotEmpty) {
        _addExcelRow(sheet, row++, 'Última Visita', carga.ultimaVisita!);
      }
      if (carga.proximaCita != null && carga.proximaCita!.isNotEmpty) {
        _addExcelRow(sheet, row++, 'Próxima Cita', carga.proximaCita!);
      }
      if (carga.codigoBarras != null && carga.codigoBarras!.isNotEmpty) {
        _addExcelRow(sheet, row++, 'Código de Barras', carga.codigoBarras!);
      }

      if (carga.alertas != null && carga.alertas!.isNotEmpty) {
        row++;
        for (final alerta in carga.alertas!) {
          _addExcelRow(sheet, row++, 'Alerta', alerta);
        }
      }

      row += 2;

      sheet.cell(CellIndex.indexByString('A$row')).value = TextCellValue('ASOCIADO TITULAR');
      sheet.cell(CellIndex.indexByString('B$row')).value = TextCellValue('');
      sheet.cell(CellIndex.indexByString('A$row')).cellStyle = headerStyle;
      sheet.cell(CellIndex.indexByString('B$row')).cellStyle = headerStyle;

      row++;

      _addExcelRow(sheet, row++, 'Nombre Completo', asociado.nombreCompleto);
      _addExcelRow(sheet, row++, 'RUT', asociado.rutFormateado);
      _addExcelRow(sheet, row++, 'Email', asociado.email);
      _addExcelRow(sheet, row++, 'Teléfono', asociado.telefono);
      _addExcelRow(sheet, row++, 'Plan', asociado.plan);
      if (asociado.sap != null && asociado.sap!.isNotEmpty) {
        _addExcelRow(sheet, row++, 'Código SAP', asociado.sap!);
      }
      _addExcelRow(sheet, row++, 'Estado', asociado.estado);

      final file = File(filePath);
      await file.writeAsBytes(excel.encode()!);

      _registrarExportacion(asociado.id!, 'Excel', filePath, carga.id!);
      return true;
    } catch (e) {
      if (kDebugMode) print('Error al generar Excel: $e');
      return false;
    }
  }

  // ========== HELPERS ==========

  static pw.Widget _buildInfoSection(String title, PdfColor titleColor, List<pw.Widget> children) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: titleColor,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Container(
          padding: const pw.EdgeInsets.all(15),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 150,
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
              style: const pw.TextStyle(color: PdfColors.grey700),
            ),
          ),
        ],
      ),
    );
  }

  static void _addExcelRow(Sheet sheet, int row, String campo, String valor) {
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        .value = TextCellValue(campo);
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
        .value = TextCellValue(valor);
  }

  static void _registrarExportacion(
      String asociadoId, String formato, String filePath, String cargaId) {
    try {
      final historialController = Get.find<HistorialController>();
      final fileName = filePath.split(Platform.pathSeparator).last;
      
      historialController.registrarExportacion(
        asociadoId: asociadoId,
        formato: formato,
        nombreArchivo: fileName,
      );
    } catch (e) {
      if (kDebugMode) print('Error al registrar exportación: $e');
    }
  }
}