import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class MaintenanceSearchFilter extends StatelessWidget {
  final TextEditingController searchController;
  final String currentFilter;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onFilterChanged;

  const MaintenanceSearchFilter({
    Key? key,
    required this.searchController,
    required this.currentFilter,
    required this.onSearchChanged,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            controller: searchController,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              prefixIcon: const Icon(LucideIcons.search, size: 18),
              hintText: "Buscar por título, ID o invernadero...",
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
                value: currentFilter,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(
                    value: "todas",
                    child: Text("Todas las solicitudes"),
                  ),
                  DropdownMenuItem(
                    value: "Pendiente",
                    child: Text("Pendientes"),
                  ),
                  DropdownMenuItem(
                    value: "En proceso",
                    child: Text("En Progreso"),
                  ),
                  DropdownMenuItem(
                    value: "Resuelto",
                    child: Text("Resueltas"),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) {
                    onFilterChanged(val);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}