import 'package:flutter/material.dart';
import 'widgets_dashboard/dashboard_tab.dart';

class DashboardHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String logoPath;
  final Color backgroundColor;

  final int? selectedTab;
  final Function(int)? onTabChanged;
  final List<String>? tabs;

  const DashboardHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.logoPath,
    this.selectedTab,
    this.onTabChanged,
    this.tabs,
    this.backgroundColor = const Color(0xff1B5E20),
  });

  bool get showTabs =>
      tabs != null &&
      tabs!.isNotEmpty &&
      selectedTab != null &&
      onTabChanged != null;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ⚡ 1. LOGO ACOTADO A TAMAÑO COMPACTO
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Image.asset(
                      logoPath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.white24,
                          child: const Icon(
                            Icons.eco,
                            color: Colors.white,
                            size: 28,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // ⚡ 2. COLUMNA DE TEXTOS DENTRO DE EXPANDED (Evita el despliegue a 422px)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // ⚡ 3. CONTENEDOR DE NOTIFICACIONES CONTROLADO
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.notifications,
                      color: Colors.white,
                      size: 22,
                    ),
                    onPressed: () {},
                  ),
                ),
              ],
            ),

            // ⚡ 4. PESTAÑAS RENDERIZADAS CON EXPANDED
            if (showTabs) ...[
              const SizedBox(height: 18),
              Row(
                children: List.generate(
                  tabs!.length,
                  (index) => Expanded(
                    child: DashboardTab(
                      title: tabs![index],
                      active: selectedTab == index,
                      onTap: () => onTabChanged!(index),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
