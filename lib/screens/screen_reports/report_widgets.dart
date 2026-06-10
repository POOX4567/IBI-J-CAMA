import 'package:flutter/material.dart';

Widget kpiCard({
  required String title,
  required String value,
  required Color color,
  required IconData icon,
}) {
  return Container(
    width: 165,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(18),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white, color.withOpacity(0.05)],
      ),
      border: Border.all(color: Colors.grey.withOpacity(0.08)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ICON BADGE
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 22),
        ),

        const SizedBox(height: 14),

        // TITLE
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 0.8,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 6),

        // VALUE
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}

Widget chartPlaceholder(String title) {
  return Container(
    height: 250,
    width: double.infinity,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(18),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white, Colors.grey.shade50],
      ),
      border: Border.all(color: Colors.grey.withOpacity(0.08)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.10),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.bar_chart, size: 40, color: Colors.blue),
        ),
        const SizedBox(height: 14),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          "Visualización dinámica de datos",
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
      ],
    ),
  );
}

Widget exportButtons() {
  return Row(
    children: [
      Expanded(
        child: _actionButton(
          color: Colors.redAccent,
          icon: Icons.picture_as_pdf,
          label: "Exportar PDF",
          onPressed: () {},
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: _actionButton(
          color: Colors.green,
          icon: Icons.table_chart,
          label: "Exportar Excel",
          onPressed: () {},
        ),
      ),
    ],
  );
}

Widget _actionButton({
  required Color color,
  required IconData icon,
  required String label,
  required VoidCallback onPressed,
}) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onPressed,
      child: Ink(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
