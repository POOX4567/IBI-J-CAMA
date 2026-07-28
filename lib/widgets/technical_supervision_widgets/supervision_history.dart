import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ibi/data/mock_data.dart';
import '../../utils/supervision_helpers.dart';

class SupervisionHistory extends StatefulWidget {
  const SupervisionHistory({Key? key}) : super(key: key);

  @override
  State<SupervisionHistory> createState() => _SupervisionHistoryState();
}

class _SupervisionHistoryState extends State<SupervisionHistory> {
  bool showHistory = false;

  @override
  Widget build(BuildContext context) {
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
              color: Colors.transparent,
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
                children: mockMaintenanceHistory.map((record) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey[50]!.withOpacity(0.3),
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
                              SupervisionHelpers.formatDate(record.date),
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
