import 'package:flutter/material.dart';

class AlertaCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String texto;
  final VoidCallback? onTap;

  const AlertaCard({
    super.key,
    required this.color,
    required this.icon,
    required this.texto,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(.12),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                texto,
                style: const TextStyle(fontSize: 15, height: 1.4),
              ),
            ),
            if (onTap != null)
              const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
