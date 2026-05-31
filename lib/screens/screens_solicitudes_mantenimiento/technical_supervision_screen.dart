import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import "package:ibi/data/mock_data.dart";

class TechnicalSupervisionScreen extends StatefulWidget {
  const TechnicalSupervisionScreen({Key? key}) : super(key: key);

  @override
  State<TechnicalSupervisionScreen> createState() =>
      _TechnicalSupervisionScreenState();
}

class _TechnicalSupervisionScreenState
    extends State<TechnicalSupervisionScreen> {
  String deviceFilter = "todos";
  bool showHistory = false; // Estado para expandir/contraer el historial

  Map<String, dynamic> _getStatusBadge(String status) {
    switch (status) {
      case "operativo":
        return {
          'icon': LucideIcons.wifi,
          'bg': Colors.green[100],
          'text': Colors.green[800],
          'label': 'OPERATIVO',
        };
      case "falla":
        return {
          'icon': LucideIcons.wifiOff,
          'bg': Colors.red[100],
          'text': Colors.red[800],
          'label': 'FALLA',
        };
      case "mantenimiento":
        return {
          'icon': LucideIcons.wrench,
          'bg': Colors.orange[100],
          'text': Colors.orange[800],
          'label': 'MANTENIMIENTO',
        };
      default:
        return {
          'icon': LucideIcons.ban,
          'bg': Colors.grey[100],
          'text': Colors.grey[800],
          'label': 'INACTIVO',
        };
    }
  }

  IconData _getDeviceTypeIcon(String type) {
    switch (type) {
      case "sensor_temperatura":
        return LucideIcons.thermometer;
      case "sensor_luz":
        return LucideIcons.sun;
      case "actuador_riego":
        return LucideIcons.play;
      case "controlador":
        return LucideIcons.settings;
      default:
        return LucideIcons.cpu;
    }
  }

  // Método auxiliar para formatear la fecha como "10 may"
  String _formatDate(DateTime date) {
    const months = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final filteredDevices =
        mockIotDevices.where((device) {
          if (deviceFilter == "todos") return true;
          return device.status == deviceFilter;
        }).toList();

    // Cambiamos a Column para poder colocar el encabezado fijo arriba
    return Column(
      children: [
        // 1. Llamamos a la sección del encabezado
        topSection(),

        // 2. El contenido original envuelto en Expanded
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildStatsGrid(),
                const SizedBox(height: 12),
                _buildDeviceList(filteredDevices),
                const SizedBox(height: 12),
                _buildFailureChart(),
                const SizedBox(height: 12),
                _buildPerformanceIndicators(),
                const SizedBox(height: 12),
                _buildMaintenanceHistory(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Nuevo método del encabezado adaptado a Supervisión Técnica
  Widget topSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF81C784)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Supervisión Técnica',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Monitoreando ${mockIotDevices.length} dispositivos IoT en tiempo real',
            style: const TextStyle(fontSize: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    int total = mockIotDevices.length;
    int operativos =
        mockIotDevices.where((d) => d.status == 'operativo').length;
    int fallas = mockIotDevices.where((d) => d.status == 'falla').length;
    int mantenimiento =
        mockIotDevices.where((d) => d.status == 'mantenimiento').length;

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      children: [
        _statCard(
          "Total Dispositivos",
          "$total",
          Colors.grey[100]!,
          Colors.grey[900]!,
        ),
        _statCard(
          "Operativos",
          "$operativos",
          Colors.green[50]!,
          Colors.green[800]!,
          icon: LucideIcons.wifi,
        ),
        _statCard(
          "Con Fallas",
          "$fallas",
          Colors.red[50]!,
          Colors.red[800]!,
          icon: LucideIcons.wifiOff,
        ),
        _statCard(
          "Mantenimiento",
          "$mantenimiento",
          Colors.orange[50]!,
          Colors.orange[800]!,
          icon: LucideIcons.wrench,
        ),
      ],
    );
  }

  Widget _statCard(
    String title,
    String value,
    Color bg,
    Color textColor, {
    IconData? icon,
    Color? border,
  }) {
    return Container(
      padding: const EdgeInsets.all(
        10,
      ), // Un poco menos de padding para dar espacio
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: border != null ? Border.all(color: border, width: 2) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Evita el Spacer()
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: textColor),
                const SizedBox(width: 4),
              ],
              // Expanded asegura que el título no desborde hacia la derecha
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 12, color: textColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          // FittedBox reduce el tamaño del número si es muy grande
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceList(List<IotDevice> devices) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Dispositivos IoT",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              DropdownButton<String>(
                value: deviceFilter,
                underline: const SizedBox(),
                // Se han añadido las opciones faltantes
                items: const [
                  DropdownMenuItem(
                    value: "todos",
                    child: Text("Todos", style: TextStyle(fontSize: 12)),
                  ),
                  DropdownMenuItem(
                    value: "operativo",
                    child: Text("Operativos", style: TextStyle(fontSize: 12)),
                  ),
                  DropdownMenuItem(
                    value: "falla",
                    child: Text("Fallas", style: TextStyle(fontSize: 12)),
                  ),
                  DropdownMenuItem(
                    value: "mantenimiento",
                    child: Text(
                      "Mantenimiento",
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  DropdownMenuItem(
                    value: "inactivo",
                    child: Text("Inactivos", style: TextStyle(fontSize: 12)),
                  ),
                ],
                onChanged: (val) => setState(() => deviceFilter = val!),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: devices.length,
            itemBuilder: (context, index) {
              final device = devices[index];
              final status = _getStatusBadge(device.status);

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[200]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getDeviceTypeIcon(device.type),
                      size: 20,
                      color: Colors.blueGrey,
                    ),
                    const SizedBox(width: 8), // Reducimos de 12 a 8
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            device.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                            maxLines: 1, // <-- Límite de líneas
                            overflow:
                                TextOverflow
                                    .ellipsis, // <-- Puntos suspensivos si no cabe
                          ),
                          Text(
                            device.greenhouse,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8), // Separador seguro
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: status['bg'],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            status['label'],
                            style: TextStyle(
                              color: status['text'],
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (device.batteryLevel != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                device.batteryLevel! < 20
                                    ? LucideIcons.batteryMedium
                                    : LucideIcons.batteryFull,
                                size: 10,
                                color:
                                    device.batteryLevel! < 20
                                        ? Colors.red
                                        : Colors.green,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                "${device.batteryLevel}%",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFailureChart() {
    // Colores exactos extraídos de la gráfica
    final List<Color> chartColors = [
      const Color(0xFF3B82F6), // Azul
      const Color(0xFFEF4444), // Rojo
      const Color(0xFFF59E0B), // Naranja
      const Color(0xFF10B981), // Verde
      const Color(0xFF8B5CF6), // Morado
      const Color(0xFF6B7280), // Gris
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título de la sección
          Row(
            children: [
              Icon(LucideIcons.alertCircle, size: 18, color: Colors.red[600]),
              const SizedBox(width: 8),
              const Text(
                "Fallas Frecuentes",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Gráfica de Barras
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY:
                    12.5, // Límite superior para dar un ligero respiro al máximo de 12
                barTouchData: BarTouchData(enabled: true),
                gridData: const FlGridData(
                  show: false,
                ), // Oculta la cuadrícula de fondo
                borderData: FlBorderData(
                  show: true,
                  border: const Border(
                    bottom: BorderSide(color: Colors.grey, width: 1),
                    left: BorderSide(color: Colors.grey, width: 1),
                    top: BorderSide.none,
                    right: BorderSide.none,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 3, // Muestra los números 0, 3, 6, 9, 12
                      reservedSize: 24,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.black54,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 70, // Espacio para el texto rotado
                      getTitlesWidget: (double value, TitleMeta meta) {
                        if (value.toInt() >= mockFailureStats.length)
                          return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Transform.rotate(
                            angle: -0.7, // Rotación diagonal
                            child: Text(
                              mockFailureStats[value.toInt()].type,
                              style: const TextStyle(
                                fontSize: 9,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups:
                    mockFailureStats.asMap().entries.map((entry) {
                      return BarChartGroupData(
                        x: entry.key,
                        barRods: [
                          BarChartRodData(
                            toY: entry.value.count.toDouble(),
                            color: chartColors[entry.key % chartColors.length],
                            width: 40, // Barras anchas
                            borderRadius:
                                BorderRadius.zero, // Sin bordes redondeados
                          ),
                        ],
                      );
                    }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 12),
          Divider(color: Colors.grey[200]),
          const SizedBox(height: 8),

          // Lista/Leyenda inferior
          ...mockFailureStats.asMap().entries.map((entry) {
            final stat = entry.value;
            final color = chartColors[entry.key % chartColors.length];

            // Lógica para los colores del pill de porcentaje
            Color badgeBgColor;
            Color badgeTextColor;
            Color badgeBorderColor;

            if (stat.percentage >= 20) {
              badgeBgColor = Colors.red[50]!;
              badgeTextColor = Colors.red[800]!;
              badgeBorderColor = Colors.red[200]!;
            } else if (stat.percentage >= 15) {
              badgeBgColor = Colors.orange[50]!;
              badgeTextColor = Colors.orange[800]!;
              badgeBorderColor = Colors.orange[300]!;
            } else {
              badgeBgColor = Colors.blueGrey[50]!;
              badgeTextColor = Colors.blueGrey[700]!;
              badgeBorderColor = Colors.blueGrey[200]!;
            }

            // Formatear el porcentaje para evitar decimales .0
            String formattedPercentage =
                stat.percentage.truncateToDouble() == stat.percentage
                    ? stat.percentage.toInt().toString()
                    : stat.percentage.toString();

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    stat.type,
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                  const Spacer(),
                  Text(
                    stat.count.toString(),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 50,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    decoration: BoxDecoration(
                      color: badgeBgColor,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: badgeBorderColor),
                    ),
                    child: Text(
                      "$formattedPercentage%",
                      style: TextStyle(color: badgeTextColor, fontSize: 11),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildPerformanceIndicators() {
    return Row(
      children: [
        Expanded(child: _perfCard("Uptime", "94.3%", "30 días", Colors.blue)),
        const SizedBox(width: 8),
        Expanded(child: _perfCard("MTTR", "4.2h", "Promedio", Colors.purple)),
        const SizedBox(width: 8),
        Expanded(child: _perfCard("Reparaciones", "12", "Total", Colors.cyan)),
      ],
    );
  }

  Widget _perfCard(
    String title,
    String value,
    String subtitle,
    MaterialColor color,
  ) {
    return Container(
      padding: const EdgeInsets.all(8), // Reducimos el padding de 12 a 8
      decoration: BoxDecoration(
        color: color[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color[300]!, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(color: color[700], fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          FittedBox(
            // <-- Evita que el número grande rompa la caja
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                color: color[900],
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(color: color[600], fontSize: 9),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // --- NUEVA SECCIÓN: Historial de Reparaciones ---
  Widget _buildMaintenanceHistory() {
    double totalCost = mockMaintenanceHistory.fold(
      0,
      (sum, item) => sum + item.cost,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => showHistory = !showHistory),
            child: Container(
              padding: const EdgeInsets.all(12),
              color:
                  Colors.transparent, // Asegura que todo el área sea clickable
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Historial de Reparaciones",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Costo total: \$${totalCost.toStringAsFixed(2)}",
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                  Icon(
                    showHistory
                        ? LucideIcons.chevronUp
                        : LucideIcons.chevronDown,
                    size: 20,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),
          ),
          if (showHistory)
            Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey[100]!)),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                children:
                    mockMaintenanceHistory.map((record) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey[50]!.withOpacity(
                            0.3,
                          ), // Fondo gris muy suave
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  record.deviceName,
                                  style: TextStyle(
                                    color: Colors.blueGrey[800],
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  "\$${record.cost.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              record.deviceId,
                              style: TextStyle(
                                color: Colors.blueGrey[300],
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              record.type,
                              style: TextStyle(
                                color: Colors.blueGrey[600],
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              record.description,
                              style: TextStyle(
                                color: Colors.blueGrey[600],
                                fontSize: 12,
                              ),
                            ),
                            if (record.parts.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                "Piezas: ${record.parts.join(', ')}",
                                style: TextStyle(
                                  color: Colors.blueGrey[400],
                                  fontSize: 11,
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                            const Divider(height: 1),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  record.performedBy,
                                  style: TextStyle(
                                    color: Colors.blueGrey[400],
                                    fontSize: 11,
                                  ),
                                ),
                                Text(
                                  _formatDate(record.date),
                                  style: TextStyle(
                                    color: Colors.blueGrey[400],
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
