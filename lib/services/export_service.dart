import 'dart:io';
import 'package:flutter/foundation.dart'; // Para kDebugMode
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:get/get.dart';
import '../models/asociado.dart';
import '../models/carga_familiar.dart';
import '../controllers/historial_controller.dart';

class ExportService {
  /// Exportar asociado a PDF
  static Future<bool> exportToPDF(
    Asociado asociado,
    List<CargaFamiliar> cargas,
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
                        color: PdfColors.lightBlue800,
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
              'Información del Asociado',
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.lightBlue800,
              ),
            ),
            pw.SizedBox(height: 20),
            _buildInfoSection('Datos Personales', [
              _buildInfoRow('Nombre Completo', asociado.nombreCompleto),
              _buildInfoRow('RUT', asociado.rutFormateado),
              _buildInfoRow(
                'Fecha de Nacimiento',
                '${asociado.fechaNacimiento.day}/${asociado.fechaNacimiento.month}/${asociado.fechaNacimiento.year}',
              ),
              _buildInfoRow('Edad', '${asociado.edad} años'),
              _buildInfoRow('Estado Civil', asociado.estadoCivil),
            ]),
            pw.SizedBox(height: 20),
            _buildInfoSection('Contacto', [
              _buildInfoRow('Email', asociado.email),
              _buildInfoRow('Teléfono', asociado.telefono),
              _buildInfoRow('Dirección', asociado.direccion),
            ]),
            pw.SizedBox(height: 20),
            _buildInfoSection('Membresía', [
              _buildInfoRow('Plan', asociado.plan),
              if (asociado.sap != null)
                _buildInfoRow('Código SAP', asociado.sap!),
              _buildInfoRow(
                'Fecha de Ingreso',
                '${asociado.fechaIngreso.day}/${asociado.fechaIngreso.month}/${asociado.fechaIngreso.year}',
              ),
            ]),
            if (cargas.isNotEmpty) ...[
              pw.SizedBox(height: 30),
              pw.Text(
                'Cargas Familiares (${cargas.length})',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.lightBlue800,
                ),
              ),
              pw.SizedBox(height: 15),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                        color: PdfColors.lightBlue50),
                    children: [
                      _buildTableCell('Nombre', isHeader: true),
                      _buildTableCell('RUT', isHeader: true),
                      _buildTableCell('Parentesco', isHeader: true),
                      _buildTableCell('Edad', isHeader: true),
                    ],
                  ),
                  ...cargas.map(
                    (carga) => pw.TableRow(
                      children: [
                        _buildTableCell(carga.nombreCompleto),
                        _buildTableCell(carga.rutFormateado),
                        _buildTableCell(carga.parentesco),
                        _buildTableCell('${carga.edad} años'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      );

      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      _registrarExportacion(asociado.id!, 'PDF', filePath);
      return true;
    } catch (e) {
      if (kDebugMode) print('Error al generar PDF: $e');
      return false;
    }
  }

  /// Exportar asociado a Excel (usa la hoja predeterminada "Sheet1")
  static Future<bool> exportToExcel(
    Asociado asociado,
    List<CargaFamiliar> cargas,
    String filePath,
  ) async {
    try {
      var excel = Excel.createExcel();
      Sheet sheet = excel['Sheet1']; // Usar hoja por defecto
      excel.setDefaultSheet('Sheet1'); // Asegurar que sea la activa

      // Estilo para headers
      CellStyle headerStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.fromHexString('#0EA5E9'),
        fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      );

      // Headers información personal
      sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue('Campo');
      sheet.cell(CellIndex.indexByString('B1')).value = TextCellValue('Valor');
      sheet.cell(CellIndex.indexByString('A1')).cellStyle = headerStyle;
      sheet.cell(CellIndex.indexByString('B1')).cellStyle = headerStyle;

      int row = 1;
      _addExcelRow(sheet, row++, 'Nombre Completo', asociado.nombreCompleto);
      _addExcelRow(sheet, row++, 'RUT', asociado.rutFormateado);
      _addExcelRow(
        sheet,
        row++,
        'Fecha de Nacimiento',
        '${asociado.fechaNacimiento.day}/${asociado.fechaNacimiento.month}/${asociado.fechaNacimiento.year}',
      );
      _addExcelRow(sheet, row++, 'Edad', '${asociado.edad} años');
      _addExcelRow(sheet, row++, 'Estado Civil', asociado.estadoCivil);
      _addExcelRow(sheet, row++, 'Email', asociado.email);
      _addExcelRow(sheet, row++, 'Teléfono', asociado.telefono);
      _addExcelRow(sheet, row++, 'Dirección', asociado.direccion);
      _addExcelRow(sheet, row++, 'Plan', asociado.plan);
      if (asociado.sap != null) {
        _addExcelRow(sheet, row++, 'Código SAP', asociado.sap!);
      }
      if (cargas.isNotEmpty) {
        row += 2;

        int headerCargasRow = row;
        List<String> headers = [
          'Nombre Carga',
          'Apellido Carga',
          'RUT Carga',
          'Parentesco',
          'Edad Carga'
        ];

        for (int i = 0; i < headers.length; i++) {
          sheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: i, rowIndex: headerCargasRow))
              .value = TextCellValue(headers[i]);
          sheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: i, rowIndex: headerCargasRow))
              .cellStyle = headerStyle;
        }

        row++;

        for (var carga in cargas) {
          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
              .value = TextCellValue(carga.nombre);
          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
              .value = TextCellValue(carga.apellido);
          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
              .value = TextCellValue(carga.rutFormateado);
          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row))
              .value = TextCellValue(carga.parentesco);
          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row))
              .value = TextCellValue('${carga.edad} años');
          row++;
        }
      }

      final file = File(filePath);
      await file.writeAsBytes(excel.encode()!);

      _registrarExportacion(asociado.id!, 'Excel', filePath);
      return true;
    } catch (e) {
      if (kDebugMode) print('Error al generar Excel: $e');
      return false;
    }
  }

  // ========== HELPERS ==========

  static pw.Widget _buildInfoSection(String title, List<pw.Widget> children) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.lightBlue700,
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

  static pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          fontSize: isHeader ? 12 : 10,
        ),
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
      String asociadoId, String formato, String filePath) {
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
