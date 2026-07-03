import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart'; // Mantenemos este, es robusto
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart'; // Necesario para compartir archivos manualmente

class ReportExporterService {
  // 🔥 PDF: Usamos Printing, que maneja el guardado y compartido nativo internamente
  static Future<void> exportToPdf({
    required String title,
    required String subtitle,
    required List<String> headers,
    required List<List<String>> rows,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter,
        build: (pw.Context context) => [
          pw.Header(level: 0, child: pw.Text(title.toUpperCase())),
          pw.Text(subtitle),
          pw.TableHelper.fromTextArray(headers: headers, data: rows),
        ],
      ),
    );

    // Printing.layoutPdf abre el menú nativo de imprimir/guardar/compartir
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: '${title.replaceAll(' ', '_')}.pdf',
    );
  }

  // 🔥 CSV (Reemplazo de Excel): Sin plugins externos, sin conflictos
  static Future<void> exportToCsv({
    required String sheetName,
    required List<String> headers,
    required List<List<String>> rows,
  }) async {
    // Crear contenido CSV
    final String csvContent = [
      headers.join(','),
      ...rows.map((r) => r.join(',')),
    ].join('\n');

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$sheetName.csv');
    await file.writeAsString(csvContent);

    // Compartir nativamente usando MethodChannel (sin share_plus)
    await _shareFileNativo(file.path);
  }

  static Future<void> _shareFileNativo(String path) async {
    const platform = MethodChannel('com.example.ibi/share');
    await platform.invokeMethod('shareFile', {'path': path});
  }
}
