import 'package:flutter/material.dart';
import 'package:ibi/models/attendance_model.dart';
import 'package:ibi/services/attendance_service.dart';

class AttendanceReportPage extends StatefulWidget {
  const AttendanceReportPage({super.key});

  @override
  State<AttendanceReportPage> createState() => _AttendanceReportPageState();
}

class _AttendanceReportPageState extends State<AttendanceReportPage>
    with SingleTickerProviderStateMixin {
  final AttendanceService _attendanceService = AttendanceService();
  late Future<AttendanceReportData> _reportFuture;
  late TabController _tabController;

  String _searchQuery = '';
  String _filterStatus = 'Todos';

  @override
  void initState() {
    super.initState();
    // ⚡ Inicialización garantizada del TabController
    _tabController = TabController(length: 2, vsync: this);
    _reportFuture = _attendanceService.fetchAttendanceReport();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: AppBar(
        title: const Text(
          'Panel de Control - Asistencia y Personal',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: const Color(0xFF1B5E20),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.amber,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          tabs: const [
            Tab(icon: Icon(Icons.dashboard_rounded), text: "Dashboard Visual"),
            Tab(icon: Icon(Icons.table_chart_rounded), text: "Tabla General"),
          ],
        ),
      ),
      body: FutureBuilder<AttendanceReportData>(
        future: _reportFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF1B5E20)),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 12),
                  Text(
                    'Error al cargar datos:\n${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(
                      () => _reportFuture = _attendanceService
                          .fetchAttendanceReport(),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B5E20),
                    ),
                    child: const Text(
                      'Reintentar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }

          final employees = snapshot.data?.employees ?? [];

          final filtered = employees.where((emp) {
            final matchesQuery = emp.name.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );
            final matchesStatus =
                _filterStatus == 'Todos' ||
                (_filterStatus == 'Activo' && emp.status == 'Presente') ||
                (_filterStatus == 'Inactivo' && emp.status != 'Presente');
            return matchesQuery && matchesStatus;
          }).toList();

          return Column(
            children: [
              _buildFilterHeader(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildDashboardTab(employees, filtered),
                    _buildTableTab(filtered),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: 'Buscar por nombre de empleado...',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF1B5E20)),
              filled: true,
              fillColor: const Color(0xFFF4F5F7),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: ['Todos', 'Activo', 'Inactivo'].map((st) {
              final selected = _filterStatus == st;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(st),
                  selected: selected,
                  selectedColor: const Color(0xFF1B5E20),
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : Colors.black87,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (_) => setState(() => _filterStatus = st),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardTab(
    List<EmployeeAttendanceModel> totalList,
    List<EmployeeAttendanceModel> filteredList,
  ) {
    final total = totalList.length;
    final activos = totalList.where((e) => e.status == 'Presente').length;
    final inactivos = total - activos;
    final pctActivos = total > 0 ? (activos / total) : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _kpiCard(
                'Total Personal',
                total.toString(),
                Icons.groups,
                Colors.blue,
              ),
              const SizedBox(width: 12),
              _kpiCard(
                'Activos',
                activos.toString(),
                Icons.check_circle,
                Colors.green,
              ),
              const SizedBox(width: 12),
              _kpiCard(
                'Inactivos',
                inactivos.toString(),
                Icons.remove_circle,
                Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rendimiento / Operatividad del Personal',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Presencia: ${(pctActivos * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        'Ausencia: ${((1 - pctActivos) * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      height: 16,
                      child: Row(
                        children: [
                          Expanded(
                            flex: activos > 0 ? activos : 1,
                            child: Container(color: Colors.green),
                          ),
                          Expanded(
                            flex: inactivos > 0 ? inactivos : 1,
                            child: Container(color: Colors.orange),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Detalle de Empleados',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredList.length,
            itemBuilder: (context, index) {
              final emp = filteredList[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF1B5E20).withOpacity(0.1),
                    child: Text(
                      emp.name.isNotEmpty ? emp.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: Color(0xFF1B5E20),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    emp.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Turno: ${emp.puntualidad} | Invernadero UTP'),
                  trailing: Chip(
                    label: Text(
                      emp.status == 'Presente' ? 'Activo' : 'Inactivo',
                    ),
                    backgroundColor: emp.status == 'Presente'
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTableTab(List<EmployeeAttendanceModel> employees) {
    if (employees.isEmpty) {
      return const Center(
        child: Text('No hay datos para mostrar en la tabla.'),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(
                const Color(0xFF1B5E20).withOpacity(0.1),
              ),
              columns: const [
                DataColumn(
                  label: Text(
                    'Nombre',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Turno',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Ubicación',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Estado',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              rows: employees.map((emp) {
                final isPresent = emp.status == 'Presente';
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        emp.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    DataCell(Text(emp.puntualidad)),
                    DataCell(const Text('Invernadero UTP')),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isPresent
                              ? Colors.green.shade50
                              : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isPresent ? 'Activo' : 'Inactivo',
                          style: TextStyle(
                            color: isPresent
                                ? Colors.green.shade800
                                : Colors.red.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _kpiCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                title,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
