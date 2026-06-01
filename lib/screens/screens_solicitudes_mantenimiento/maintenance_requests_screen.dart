import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import "package:ibi/data/mock_data.dart";

class MaintenanceRequestsScreen extends StatefulWidget {
  const MaintenanceRequestsScreen({Key? key}) : super(key: key);

  @override
  State<MaintenanceRequestsScreen> createState() =>
      _MaintenanceRequestsScreenState();
}

class _MaintenanceRequestsScreenState extends State<MaintenanceRequestsScreen> {
  String filter = "todas";
  String searchTerm = "";
  String? expandedCardId;
  final TextEditingController _searchController = TextEditingController();

  Map<String, dynamic> _getPriorityBadge(String priority) {
    switch (priority) {
      case "alta":
        return {
          'bg': Colors.red[100],
          'text': Colors.red[800],
          'border': Colors.red[300],
          'label': 'URGENTE',
        };
      case "media":
        return {
          'bg': Colors.yellow[100],
          'text': Colors.yellow[800],
          'border': Colors.yellow[300],
          'label': 'MEDIA',
        };
      case "baja":
        return {
          'bg': Colors.green[100],
          'text': Colors.green[800],
          'border': Colors.green[300],
          'label': 'BAJA',
        };
      default:
        return {
          'bg': Colors.grey[100],
          'text': Colors.grey[800],
          'border': Colors.grey[300],
          'label': 'N/A',
        };
    }
  }

  Map<String, dynamic> _getStatusBadge(String status) {
    switch (status) {
      case "pendiente":
        return {
          'icon': LucideIcons.clock,
          'bg': Colors.orange[100],
          'text': Colors.orange[800],
          'border': Colors.orange[300],
          'label': 'Pendiente',
        };
      case "en_progreso":
        return {
          'icon': LucideIcons.alertCircle,
          'bg': Colors.blue[100],
          'text': Colors.blue[800],
          'border': Colors.blue[300],
          'label': 'En Progreso',
        };
      case "completada":
        return {
          'icon': LucideIcons.checkCircle,
          'bg': Colors.green[100],
          'text': Colors.green[800],
          'border': Colors.green[300],
          'label': 'Completada',
        };
      case "cancelada":
        return {
          'icon': LucideIcons.xCircle,
          'bg': Colors.grey[100],
          'text': Colors.grey[800],
          'border': Colors.grey[300],
          'label': 'Cancelada',
        };
      default:
        return {
          'icon': null,
          'bg': Colors.grey[100],
          'text': Colors.grey[800],
          'border': Colors.grey[300],
          'label': status,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filtramos la data estática
    final filteredRequests =
        mockMaintenanceRequests.where((request) {
          final matchesFilter = filter == "todas" || request.status == filter;
          final matchesSearch =
              request.title.toLowerCase().contains(searchTerm.toLowerCase()) ||
              request.greenhouse.toLowerCase().contains(
                searchTerm.toLowerCase(),
              ) ||
              request.id.toLowerCase().contains(searchTerm.toLowerCase());
          return matchesFilter && matchesSearch;
        }).toList();

    // Cambiamos el contenedor principal a un Column
    return Column(
      children: [
        // 1. Aquí llamamos a tu encabezado para que se renderice
        topSection(),

        // 2. El resto de la pantalla va dentro de un Expanded para que pueda hacer scroll
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildStatsGrid(),
                const SizedBox(height: 12),
                _buildSearchAndFilter(),
                const SizedBox(height: 12),
                _buildRequestsList(filteredRequests),
              ],
            ),
          ),
        ),
      ],
    );
  }

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
            'Solicitudes de Mantenimiento',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Gestionando ${mockMaintenanceRequests.length} solicitudes en los invernaderos',
            style: const TextStyle(fontSize: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    int total = mockMaintenanceRequests.length;
    int urgentes =
        mockMaintenanceRequests.where((r) => r.priority == 'alta').length;
    int pendientes =
        mockMaintenanceRequests.where((r) => r.status == 'pendiente').length;
    int enProgreso =
        mockMaintenanceRequests.where((r) => r.status == 'en_progreso').length;

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      children: [
        // Pasamos el border e icon usando su nombre de parámetro
        _statCard(
          "Total Solicitudes",
          "$total",
          Colors.grey[100]!,
          Colors.grey[900]!,
          border: Colors.grey[300]!,
        ),
        _statCard(
          "Urgentes",
          "$urgentes",
          Colors.red[50]!,
          Colors.red[800]!,
          border: Colors.red[300]!,
          icon: LucideIcons.alertCircle,
        ),
        _statCard(
          "Pendientes",
          "$pendientes",
          Colors.orange[50]!,
          Colors.orange[800]!,
          border: Colors.orange[300]!,
          icon: LucideIcons.clock,
        ),
        _statCard(
          "En Progreso",
          "$enProgreso",
          Colors.blue[50]!,
          Colors.blue[800]!,
          border: Colors.blue[300]!,
          icon: LucideIcons.alertCircle,
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

  Widget _buildSearchAndFilter() {
    // (Este método se mantiene igual que en tu código anterior)
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => searchTerm = val),
            decoration: InputDecoration(
              prefixIcon: const Icon(LucideIcons.search, size: 18),
              hintText: "Buscar...",
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: filter,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(
                    value: "todas",
                    child: Text("Todas las solicitudes"),
                  ),
                  DropdownMenuItem(
                    value: "pendiente",
                    child: Text("Pendientes"),
                  ),
                  DropdownMenuItem(
                    value: "en_progreso",
                    child: Text("En Progreso"),
                  ),
                  DropdownMenuItem(
                    value: "completada",
                    child: Text("Completadas"),
                  ),
                ],
                onChanged: (val) => setState(() => filter = val!),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsList(List<MaintenanceRequest> requests) {
    if (requests.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Text(
          "No se encontraron solicitudes",
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final req = requests[index];
        final priority = _getPriorityBadge(req.priority);
        final status = _getStatusBadge(req.status);
        final isExpanded = expandedCardId == req.id;

        return GestureDetector(
          onTap:
              () => setState(() => expandedCardId = isExpanded ? null : req.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildBadge(
                            priority['label'],
                            priority['bg'],
                            priority['text'],
                            priority['border'],
                          ),
                          const SizedBox(width: 8),
                          _buildBadge(
                            status['label'],
                            status['bg'],
                            status['text'],
                            status['border'],
                            icon: status['icon'],
                          ),
                          const Spacer(),
                          Icon(
                            isExpanded
                                ? LucideIcons.chevronUp
                                : LucideIcons.chevronDown,
                            size: 16,
                            color: Colors.grey[400],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        req.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        "#${req.id}",
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        req.greenhouse,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (isExpanded)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: Colors.grey[100]!)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          req.description,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Reportado por",
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 11,
                                  ),
                                ),
                                Text(
                                  req.reportedBy,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "Asignado a",
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 11,
                                  ),
                                ),
                                Text(
                                  req.assignedTo ?? "Sin asignar",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // --- NUEVA SECCIÓN DE ACCIONES ---
                        const SizedBox(height: 16),
                        const Divider(height: 1),
                        const SizedBox(height: 12),
                        Column(
                          children: [
                            // Primera fila de botones: Chat y Estado
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed:
                                        () => _abrirChatSimulado(context, req),
                                    icon: const Icon(
                                      LucideIcons.messageSquare,
                                      size: 16,
                                    ),
                                    label: const Text("Chat"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2E7D32),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed:
                                        () => _mostrarOpcionesDeEstado(
                                          context,
                                          req,
                                        ),
                                    icon: const Icon(
                                      LucideIcons.refreshCw,
                                      size: 16,
                                    ),
                                    label: const Text("Estado"),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFF5D4037),
                                      side: BorderSide(
                                        color: Colors.grey[300]!,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Segunda fila de botones: Prioridad y Asignar
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed:
                                        () => _mostrarOpcionesDePrioridad(
                                          context,
                                          req,
                                        ),
                                    icon: const Icon(
                                      LucideIcons.alertTriangle,
                                      size: 16,
                                    ),
                                    label: const Text("Prioridad"),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFF5D4037),
                                      side: BorderSide(
                                        color: Colors.grey[300]!,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed:
                                        () => _mostrarOpcionesDeAsignacion(
                                          context,
                                          req,
                                        ),
                                    icon: const Icon(
                                      LucideIcons.userPlus,
                                      size: 16,
                                    ),
                                    label: const Text("Asignar"),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFF5D4037),
                                      side: BorderSide(
                                        color: Colors.grey[300]!,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // --- FIN DE LA NUEVA SECCIÓN ---
                        // --- FIN DE LA NUEVA SECCIÓN ---
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBadge(
    String label,
    Color bg,
    Color text,
    Color border, {
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: text),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: text,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarOpcionesDeEstado(BuildContext context, MaintenanceRequest req) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.wrench, color: Colors.black87),
                    const SizedBox(width: 12),
                    Text(
                      "Actualizar Solicitud #${req.id}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(LucideIcons.clock, color: Colors.orange[600]),
                title: const Text("Marcar como Pendiente"),
                onTap: () => _actualizarEstado(req, "pendiente"),
              ),
              ListTile(
                leading: Icon(LucideIcons.alertCircle, color: Colors.blue[600]),
                title: const Text("Marcar en Progreso"),
                onTap: () => _actualizarEstado(req, "en_progreso"),
              ),
              ListTile(
                leading: Icon(
                  LucideIcons.checkCircle,
                  color: Colors.green[600],
                ),
                title: const Text("Cerrar Solicitud (Completada)"),
                onTap: () => _actualizarEstado(req, "completada"),
              ),
              ListTile(
                leading: Icon(LucideIcons.xCircle, color: Colors.grey[600]),
                title: const Text("Cancelar Solicitud"),
                onTap: () => _actualizarEstado(req, "cancelada"),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _actualizarEstado(MaintenanceRequest req, String nuevoEstado) {
    // Cierra el BottomSheet
    Navigator.pop(context);

    // Por ahora actualizamos el estado localmente en el mock data.
    // Cuando conectes esto a tu API REST o backend con Node.js,
    // aquí es donde harás la petición PUT/PATCH a tu base de datos relacional.
    setState(() {
      req.status = nuevoEstado;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Estado actualizado a: $nuevoEstado'),
        backgroundColor: const Color(0xFF2E7D32),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ==========================================
  // FUNCIONES PARA CAMBIAR PRIORIDAD
  // ==========================================
  void _mostrarOpcionesDePrioridad(
    BuildContext context,
    MaintenanceRequest req,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      LucideIcons.alertTriangle,
                      color: Colors.black87,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Prioridad para #${req.id}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(
                  LucideIcons.arrowUpCircle,
                  color: Colors.red[600],
                ),
                title: const Text("Urgente (Alta)"),
                onTap: () => _actualizarPrioridad(req, "alta"),
              ),
              ListTile(
                leading: Icon(
                  LucideIcons.minusCircle,
                  color: Colors.yellow[800],
                ),
                title: const Text("Media"),
                onTap: () => _actualizarPrioridad(req, "media"),
              ),
              ListTile(
                leading: Icon(
                  LucideIcons.arrowDownCircle,
                  color: Colors.green[600],
                ),
                title: const Text("Baja"),
                onTap: () => _actualizarPrioridad(req, "baja"),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _actualizarPrioridad(MaintenanceRequest req, String nuevaPrioridad) {
    Navigator.pop(context);
    setState(() => req.priority = nuevaPrioridad);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Prioridad actualizada a: $nuevaPrioridad'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
    );
  }

  // ==========================================
  // FUNCIONES PARA ASIGNAR ENCARGADO
  // ==========================================
  void _mostrarOpcionesDeAsignacion(
    BuildContext context,
    MaintenanceRequest req,
  ) {
    // Lista simulada de técnicos/empleados disponibles
    final List<String> tecnicos = [
      "Juan Pérez",
      "Roberto Gómez",
      "Ana Martínez",
      "Marcus Rivera",
      "Carlos Mendoza",
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                ),
                child: const Row(
                  children: [
                    Icon(LucideIcons.users, color: Colors.black87),
                    SizedBox(width: 12),
                    Text(
                      "Asignar Técnico",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Generamos la lista de opciones
              ...tecnicos.map(
                (tecnico) => ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF81C784),
                    radius: 14,
                    child: Icon(Icons.person, size: 16, color: Colors.white),
                  ),
                  title: Text(tecnico),
                  onTap: () => _actualizarAsignacion(req, tecnico),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _actualizarAsignacion(MaintenanceRequest req, String nuevoEncargado) {
    Navigator.pop(context);
    setState(() => req.assignedTo = nuevoEncargado);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Solicitud asignada a $nuevoEncargado'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
    );
  }

  // ==========================================
  // FUNCIÓN PARA SIMULAR CHAT
  // ==========================================
  void _abrirChatSimulado(BuildContext context, MaintenanceRequest req) {
    final persona = req.assignedTo ?? req.reportedBy;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(LucideIcons.messageSquare, color: Color(0xFF2E7D32)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Chat con $persona',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Sobre la solicitud #${req.id}: ${req.title}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              const TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Escribe un mensaje de seguimiento...',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF2E7D32), width: 2),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Mensaje enviado exitosamente'),
                    backgroundColor: Color(0xFF2E7D32),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
              ),
              child: const Text(
                'Enviar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
