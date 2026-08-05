import 'package:flutter/material.dart';

class DashboardTab extends StatelessWidget {
  final String title;
  final bool active;
  final VoidCallback onTap;

  const DashboardTab({
    super.key,
    required this.title,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: active ? Colors.white : Colors.white24,
        borderRadius: BorderRadius.circular(14),
        boxShadow: active
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Center(
              child: Text(
                title,
                style: TextStyle(
                  color: active ? const Color(0xFF1B5E20) : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
