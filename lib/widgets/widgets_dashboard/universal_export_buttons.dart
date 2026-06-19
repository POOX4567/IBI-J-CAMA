import 'package:flutter/material.dart';
import '../../services/report_exporter_service.dart';

class UniversalExportButtons extends StatelessWidget {
  final String title;
  final String subtitle;
  final String csvSheetName;
  final List<String> headers;
  final List<List<String>> rows;

  const UniversalExportButtons({
    super.key,
    required this.title,
    required this.subtitle,
    required this.csvSheetName,
    required this.headers,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildButton(
          label: "Exportar PDF",
          icon: Icons.picture_as_pdf,
          color: Colors.redAccent.shade700,
          onPressed: () => ReportExporterService.exportToPdf(
            title: title,
            subtitle: subtitle,
            headers: headers,
            rows: rows,
          ),
        ),
        const SizedBox(width: 12),
        _buildButton(
          label: "Exportar CSV",
          icon: Icons.analytics_outlined,
          color: const Color(0xFF004D40), // Tu Teal primario
          onPressed: () => ReportExporterService.exportToCsv(
            sheetName: csvSheetName,
            headers: headers,
            rows: rows,
          ),
        ),
      ],
    );
  }

  Widget _buildButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
      ),
    );
  }
}
