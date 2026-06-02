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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset(logoPath, width: 100, height: 100),

                  const SizedBox(width: 12),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(Icons.notifications, color: Colors.white),
              ),
            ],
          ),

          if (showTabs) ...[
            const SizedBox(height: 25),

            Row(
              children: List.generate(
                tabs!.length,
                (index) => DashboardTab(
                  title: tabs![index],
                  active: selectedTab == index,
                  onTap: () => onTabChanged!(index),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
