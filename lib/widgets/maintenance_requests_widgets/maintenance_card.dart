import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ibi/data/mock_data.dart';
import '../../utils/maintenance_helpers.dart';
import 'package:url_launcher/url_launcher.dart';

class MaintenanceCard extends StatelessWidget {
  final MaintenanceRequest request;
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final File? image;
  final Function(ImageSource) onPickImage;
  final VoidCallback onRemoveImage;
  final VoidCallback onStateUpdated;
  final VoidCallback? onEditRequested;

  const MaintenanceCard({
    Key? key,
    required this.request,
    required this.isExpanded,
    required this.onToggleExpand,
    this.image,
    required this.onPickImage,
    required this.onRemoveImage,
    required this.onStateUpdated,
    this.onEditRequested,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final priority = MaintenanceHelpers.getPriorityBadge(request.priority);
    final status = MaintenanceHelpers.getStatusBadge(request.status);

    return GestureDetector(
      onTap: onToggleExpand,
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
                      MaintenanceHelpers.buildBadge(
                        priority['label'],
                        priority['bg'],
                        priority['text'],
                        priority['border'],
                      ),
                      const SizedBox(width: 8),
                      MaintenanceHelpers.buildBadge(
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
                    request.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    "#${request.id} - ${request.greenhouse}",
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
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
                      request.description,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(height: 12),

                    // SECCIÓN DE EVIDENCIA
                    _buildEvidenceSection(context),
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
                              request.reportedBy,
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
                              request.assignedTo ?? "Sin asignar",
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 12),

                    // AQUÍ ESTÁN TUS BOTONES DE ACCIÓN
                    _buildActionButtons(context),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEvidenceSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Evidencia fotográfica",
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 6),
        if (image == null)
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => onPickImage(ImageSource.camera),
                  icon: const Icon(LucideIcons.camera, size: 14),
                  label: const Text(
                    "Tomar Foto",
                    style: TextStyle(fontSize: 11),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blueGrey[700],
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => onPickImage(ImageSource.gallery),
                  icon: const Icon(LucideIcons.image, size: 14),
                  label: const Text("Galería", style: TextStyle(fontSize: 11)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blueGrey[700],
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ],
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  image!,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (ctx) => SafeArea(
                          child: Wrap(
                            children: [
                              ListTile(
                                leading: const Icon(LucideIcons.camera),
                                title: const Text("Usar Cámara"),
                                onTap: () {
                                  Navigator.pop(ctx);
                                  onPickImage(ImageSource.camera);
                                },
                              ),
                              ListTile(
                                leading: const Icon(LucideIcons.image),
                                title: const Text("Buscar en Galería"),
                                onTap: () {
                                  Navigator.pop(ctx);
                                  onPickImage(ImageSource.gallery);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    icon: const Icon(
                      LucideIcons.refreshCw,
                      size: 12,
                      color: Colors.blue,
                    ),
                    label: const Text(
                      "Cambiar",
                      style: TextStyle(fontSize: 11, color: Colors.blue),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: onRemoveImage,
                    icon: const Icon(
                      LucideIcons.trash2,
                      size: 12,
                      color: Colors.red,
                    ),
                    label: const Text(
                      "Eliminar",
                      style: TextStyle(fontSize: 11, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            if (onEditRequested != null) ...[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEditRequested,
                  icon: const Icon(LucideIcons.pencil, size: 16),
                  label: const Text("Editar"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF5D4037),
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _mostrarOpcionesDeEstado(context),
                icon: const Icon(LucideIcons.refreshCw, size: 16),
                label: const Text("Estado"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF5D4037),
                  side: BorderSide(color: Colors.grey[300]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _mostrarOpcionesDeContacto(context),
                icon: const Icon(LucideIcons.phone, size: 16),
                label: const Text("Contactar"),
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
                onPressed: () => _mostrarOpcionesDePrioridad(context),
                icon: const Icon(LucideIcons.alertTriangle, size: 16),
                label: const Text("Tipo"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF5D4037),
                  side: BorderSide(color: Colors.grey[300]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _mostrarOpcionesDeEstado(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(LucideIcons.clock, color: Colors.orange[600]),
              title: const Text("Marcar como Pendiente"),
              onTap: () {
                request.status = "Pendiente";
                _cerrarYActualizar(ctx, 'Estado actualizado');
              },
            ),
            ListTile(
              leading: Icon(LucideIcons.alertCircle, color: Colors.blue[600]),
              title: const Text("Marcar en Progreso"),
              onTap: () {
                request.status = "En proceso";
                _cerrarYActualizar(ctx, 'Estado actualizado');
              },
            ),
            ListTile(
              leading: Icon(LucideIcons.checkCircle, color: Colors.green[600]),
              title: const Text("Cerrar Solicitud (Resuelto)"),
              onTap: () {
                request.status = "Resuelto";
                _cerrarYActualizar(ctx, 'Solicitud completada');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarOpcionesDePrioridad(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(LucideIcons.arrowUpCircle, color: Colors.red[600]),
              title: const Text("Correctivo"),
              onTap: () {
                request.priority = "Correctivo";
                _cerrarYActualizar(ctx, 'Tipo actualizado');
              },
            ),
            ListTile(
              leading: Icon(LucideIcons.arrowDownCircle, color: Colors.green[600]),
              title: const Text("Preventivo"),
              onTap: () {
                request.priority = "Preventivo";
                _cerrarYActualizar(ctx, 'Tipo actualizado');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _cerrarYActualizar(BuildContext context, String mensaje) {
    Navigator.pop(context);
    onStateUpdated();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: const Color(0xFF2E7D32),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ==========================================
  // LÓGICA DE LOS MENÚS (BOTTOM SHEETS)
  // ==========================================

  void _mostrarOpcionesDeContacto(BuildContext context) {
    final persona = request.assignedTo ?? request.reportedBy;
    const numeroTelefono = "9991234567";

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
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
                  const Icon(LucideIcons.user, color: Colors.black87),
                  const SizedBox(width: 12),
                  Text(
                    "Contactar a $persona",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(LucideIcons.phoneCall, color: Colors.green),
              title: const Text("Llamar por teléfono"),
              subtitle: const Text(numeroTelefono),
              onTap: () {
                Navigator.pop(ctx);
                _hacerLlamada(numeroTelefono, context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _hacerLlamada(String numero, BuildContext context) async {
    final Uri urlLlamada = Uri(scheme: 'tel', path: numero);

    try {
      if (await canLaunchUrl(urlLlamada)) {
        await launchUrl(urlLlamada);
      } else {
        throw 'No se pudo abrir la aplicación de llamadas';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al realizar la llamada: $e"),
          backgroundColor: Colors.red[800],
        ),
      );
    }
  }
}
