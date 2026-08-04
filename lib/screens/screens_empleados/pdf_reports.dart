import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfReports {
  static Future<Uint8List> generarReporteEmpleado({
    required String nombre,
    required String rol,
    required String zona,
    required String periodo,
    required List<String> estadisticas,
    required Map<String, dynamic> datosAsistencia,
    required List<Map<String, dynamic>> actividades,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Container(
            padding: pw.EdgeInsets.only(bottom: 20),
            decoration: pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.green700, width: 2),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'IBI-Jícama',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.green700,
                      ),
                    ),
                    pw.Text(
                      'Control de Invernadero',
                      style: pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
                pw.Text(
                  'Reporte de Empleado',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Container(
            padding: pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColors.green50,
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Información del Empleado',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.green700,
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Row(
                  children: [
                    _buildInfoRow('Nombre:', nombre),
                    pw.SizedBox(width: 40),
                    _buildInfoRow('Rol:', rol),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Row(
                  children: [
                    _buildInfoRow('Zona:', zona),
                    pw.SizedBox(width: 40),
                    _buildInfoRow('Período:', periodo),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Container(
            padding: pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Resumen de Asistencia',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard(
                      'Presentes',
                      datosAsistencia['presentes'].toString(),
                      PdfColors.green,
                    ),
                    _buildStatCard(
                      'Retardos',
                      datosAsistencia['retardos'].toString(),
                      PdfColors.orange,
                    ),
                    _buildStatCard(
                      'Faltas',
                      datosAsistencia['faltas'].toString(),
                      PdfColors.red,
                    ),
                    _buildStatCard(
                      'Asistencia',
                      '${datosAsistencia['porcentaje']}%',
                      PdfColors.blue,
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Container(
            padding: pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Estadísticas Detalladas',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 12),
                ...estadisticas.map(
                  (stat) => pw.Padding(
                    padding: pw.EdgeInsets.only(bottom: 6),
                    child: pw.Row(
                      children: [
                        pw.Container(
                          width: 6,
                          height: 6,
                          decoration: const pw.BoxDecoration(
                            color: PdfColors.green700,
                            shape: pw.BoxShape.circle,
                          ),
                        ),
                        pw.SizedBox(width: 8),
                        pw.Text(stat, style: pw.TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (actividades.isNotEmpty) ...[
            pw.SizedBox(height: 20),
            pw.Container(
              padding: pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Actividades Realizadas',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 12),
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey300),
                    children: [
                      pw.TableRow(
                        decoration: pw.BoxDecoration(color: PdfColors.grey100),
                        children: [
                          _buildHeaderCell('Actividad'),
                          _buildHeaderCell('Fecha'),
                          _buildHeaderCell('Estado'),
                        ],
                      ),
                      ...actividades.map(
                        (actividad) => pw.TableRow(
                          children: [
                            _buildCell(actividad['actividad']),
                            _buildCell(actividad['fecha']),
                            _buildCell(actividad['estado']),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          pw.SizedBox(height: 20),
          pw.Container(
            alignment: pw.Alignment.center,
            child: pw.Text(
              'Reporte generado el ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey500),
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Row(
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
        ),
        pw.SizedBox(width: 8),
        pw.Text(value, style: pw.TextStyle(fontSize: 12)),
      ],
    );
  }

  static pw.Widget _buildStatCard(String title, String value, PdfColor color) {
    return pw.Container(
      width: 80,
      padding: pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: PdfColors.green50,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            title,
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildHeaderCell(String text) {
    return pw.Container(
      padding: pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static pw.Widget _buildCell(String text) {
    return pw.Container(
      padding: pw.EdgeInsets.all(8),
      child: pw.Text(text, style: pw.TextStyle(fontSize: 10)),
    );
  }
}
