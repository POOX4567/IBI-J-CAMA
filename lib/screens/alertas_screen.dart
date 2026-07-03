import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:intl/intl.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class AlertasScreen extends StatefulWidget {
  const AlertasScreen({super.key});

  @override
  State<AlertasScreen> createState() => _AlertasScreenState();
}

class _AlertasScreenState extends State<AlertasScreen> {

final fechaActual =
    DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

    String estadoConexion = 'Verificando...';

    Future<void> verificarConexion() async {
  final resultado = await Connectivity().checkConnectivity();

  setState(() {
    if (resultado.contains(ConnectivityResult.none)) {
      estadoConexion = 'Sin conexión';
    } else {
      estadoConexion = 'Conectado';
    }
  });
}

  bool _marcadasLeidas = false;

  @override
void initState() {
  super.initState();
  verificarConexion();
}

  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color lightGreen = Color(0xFF66BB6A);
  static const Color brown = Color(0xFF5D4037);
  static const Color background = Color(0xFFF6F1F7);
  static const Color warning = Color(0xFFF57C00);
  static const Color critical = Color(0xFFD32F2F);
  static const Color infoBlue = Color(0xFF1976D2);

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 90),
          children: [
            _Header(
                fechaActual: fechaActual,
  estadoConexion: estadoConexion,
  onMarkRead: () {
    setState(() {
      _marcadasLeidas = true;
    });
  },
),

            const SizedBox(height: 16),

            const SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(label: 'Todas', selected: true),
                  _FilterChip(label: 'Sensores'),
                  _FilterChip(label: 'Mantenimiento'),
                  _FilterChip(label: 'Horarios'),
                  _FilterChip(label: 'Prioridad'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Alertas recientes',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: brown,
              ),
            ),

            const SizedBox(height: 12),

            _AlertCard(
              title: 'Temperatura crítica',
              description:
                  'La Zona C alcanzó 35°C. Se requiere revisión inmediata para evitar daño en el cultivo.',
              time: 'Hace 2 min',
              category: 'Sensor',
              priority: 'Crítica',
              color: critical,
              icon: Icons.device_thermostat,
              read: _marcadasLeidas,
              primaryAction: 'Ver datos',
              onPrimary: () => _showSimpleDialog(
                context,
                'Datos de temperatura',
                'Zona C\nTemperatura actual: 35°C\nEstado: Crítico',
              ),
            ),

            _AlertCard(
              title: 'Baja humedad del suelo',
              description:
                  'La Zona B presenta humedad menor al 30% en dos camas de cultivo.',
              time: 'Hace 45 min',
              category: 'Humedad',
              priority: 'Advertencia',
              color: warning,
              icon: Icons.water_drop_outlined,
              read: _marcadasLeidas,
              primaryAction: 'Ver detalles',
              onPrimary: () => _showSimpleDialog(
                context,
                'Detalle de humedad',
                'Zona B\nCama 1: 28%\nCama 2: 29%\nRequiere seguimiento del encargado.',
              ),
            ),

            _AlertCard(
              title: 'Falla técnica detectada',
              description:
                  'Sensor de humedad desconectado en Zona A. Se generó reporte para mantenimiento.',
              time: 'Hace 1 hora',
              category: 'Falla técnica',
              priority: 'Urgente',
              color: critical,
              icon: Icons.warning_amber_rounded,
              read: _marcadasLeidas,
              primaryAction: 'Revisar',
              onPrimary: () => _showSimpleDialog(
                context,
                'Falla técnica',
                'Sensor afectado: Humedad de suelo\nZona: A\nEstado: Sin conexión',
              ),
            ),

            _AlertCard(
              title: 'Mantenimiento programado',
              description:
                  'Inspección de bomba de riego programada para mañana a las 09:00 AM.',
              time: 'Hace 3 horas',
              category: 'Mantenimiento',
              priority: 'Pendiente',
              color: primaryGreen,
              icon: Icons.handyman,
              read: _marcadasLeidas,
              primaryAction: 'Confirmar',
              onPrimary: () => _showSimpleDialog(
                context,
                'Mantenimiento confirmado',
                'La inspección de la bomba de riego fue marcada como revisada.',
              ),
            ),

            _AlertCard(
              title: 'Cambio de horario',
              description:
                  'El horario de revisión de la Zona A fue actualizado de 08:00 AM a 10:00 AM.',
              time: 'Hace 5 horas',
              category: 'Horario',
              priority: 'Informativo',
              color: infoBlue,
              icon: Icons.schedule,
              read: _marcadasLeidas,
            ),

            _AlertCard(
              title: 'Tarea pendiente',
              description:
                  'Checklist de supervisión diaria pendiente para Zona B.',
              time: 'Hoy',
              category: 'Actividad',
              priority: 'Pendiente',
              color: warning,
              icon: Icons.checklist,
              read: _marcadasLeidas,
            ),

            _AlertCard(
              title: 'Actualización del sistema',
              description:
                  'Firmware de sensores actualizado correctamente en las zonas registradas.',
              time: 'Ayer',
              category: 'Sistema',
              priority: 'Informativo',
              color: primaryGreen,
              icon: Icons.system_update_alt,
              read: _marcadasLeidas,
            ),
          ],
        ),
      ),
    );
  }

  static void _showSimpleDialog(
    BuildContext context,
    String title,
    String message,
  ) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onMarkRead;
   final String fechaActual;
   final String estadoConexion;

  const _Header({
    required this.onMarkRead,
     required this.fechaActual,
     required this.estadoConexion,
    });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _AlertasScreenState.primaryGreen,
            _AlertasScreenState.lightGreen,
          ],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
  'Centro de\nAlertas',
  style: TextStyle(
    fontSize: 29,
    height: 1.25,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  ),
),

const SizedBox(height: 12),

badges.Badge(
  badgeContent: const Text(
    '7',
    style: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 11,
    ),
  ),
  child: const Text(
    'Alertas pendientes',
    style: TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ),
  ),
),

const SizedBox(height: 14),

const Text(
  'Monitoreando avisos importantes del sistema',
  style: TextStyle(
    fontSize: 17,
    height: 1.4,
    color: Colors.white70,
    fontWeight: FontWeight.w500,
  ),
),
const SizedBox(height: 6),

Text(
  'Última actualización: $fechaActual',
  
  style: const TextStyle(
    fontSize: 14,
    color: Colors.white70,
  ),
),
Text(
  'Estado de red: $estadoConexion',
  style: const TextStyle(
    fontSize: 14,
    color: Colors.white70,
  ),
),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onMarkRead,
              icon: const Icon(Icons.done_all),
              label: const Text('Marcar todo como leído'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _AlertasScreenState.primaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;

  const _FilterChip({
    required this.label,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: selected ? _AlertasScreenState.primaryGreen : Colors.white,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: selected
              ? _AlertasScreenState.primaryGreen
              : Colors.grey.shade300,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : _AlertasScreenState.brown,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final String title;
  final String description;
  final String time;
  final String category;
  final String priority;
  final Color color;
  final IconData icon;
  final bool read;
  final String? primaryAction;
  final VoidCallback? onPrimary;

  const _AlertCard({
    required this.title,
    required this.description,
    required this.time,
    required this.category,
    required this.priority,
    required this.color,
    required this.icon,
    required this.read,
    this.primaryAction,
    this.onPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: read ? .55 : 1,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(left: BorderSide(color: color, width: 5)),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.09),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: color.withOpacity(.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 29),
                  ),

                  const SizedBox(width: 13),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _AlertasScreenState.brown,
                                ),
                              ),
                            ),
                            if (!read)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 5),

                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.35,
                            color: Colors.grey.shade700,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _MiniBadge(label: category, color: color),
                            _MiniBadge(label: priority, color: color),
                            _TimeBadge(time: time),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              if (primaryAction != null) ...[
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onPrimary,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                    child: Text(primaryAction!),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _MiniBadge({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(.45)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _TimeBadge extends StatelessWidget {
  final String time;

  const _TimeBadge({required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        time,
        style: const TextStyle(
          fontSize: 12,
          color: _AlertasScreenState.brown,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}