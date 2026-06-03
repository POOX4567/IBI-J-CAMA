import 'package:flutter/material.dart';
import 'report_widgets.dart';

class ProductionReportPage extends StatelessWidget {
  const ProductionReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      // ✅ SOLO BARRA SUPERIOR
      appBar: AppBar(
        title: const Text("Reporte de Producción"),
        backgroundColor: Colors.green,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                kpiCard(
                  title: "Total",
                  value: "2820 Kg",
                  color: Colors.green,
                  icon: Icons.eco,
                ),
                const SizedBox(width: 12),
                kpiCard(
                  title: "Meta",
                  value: "3360 Kg",
                  color: Colors.orange,
                  icon: Icons.flag,
                ),
              ],
            ),

            const SizedBox(height: 20),

            chartPlaceholder("Producción Mensual"),

            const SizedBox(height: 20),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 30,
                  columns: const [
                    DataColumn(label: Text("Cultivo")),
                    DataColumn(label: Text("Kg")),
                    DataColumn(label: Text("%")),
                  ],
                  rows: const [
                    DataRow(
                      cells: [
                        DataCell(Text("Jícama Agua")),
                        DataCell(Text("1200")),
                        DataCell(Text("92%")),
                      ],
                    ),
                    DataRow(
                      cells: [
                        DataCell(Text("Jícama Leche")),
                        DataCell(Text("980")),
                        DataCell(Text("81%")),
                      ],
                    ),
                    DataRow(
                      cells: [
                        DataCell(Text("Pepino")),
                        DataCell(Text("640")),
                        DataCell(Text("74%")),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            exportButtons(),
          ],
        ),
      ),
    );
  }
}
