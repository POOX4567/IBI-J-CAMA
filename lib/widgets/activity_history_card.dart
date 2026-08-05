import 'package:flutter/material.dart';

import '../models/activity_history_model.dart';

class ActivityHistoryCard extends StatelessWidget {
  final ActivityHistoryModel activity;

  const ActivityHistoryCard({
    super.key,
    required this.activity,
  });

  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color brown = Color(0xFF5D4037);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              children: [

                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryGreen.withOpacity(.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.history,
                    color: primaryGreen,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Text(
                    activity.activity,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: brown,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Text(
              activity.description,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 18),

            Row(
              children: [

                const Icon(
                  Icons.person,
                  color: primaryGreen,
                  size: 20,
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: Text(
                    activity.userName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [

                const Icon(
                  Icons.calendar_today,
                  color: Colors.grey,
                  size: 18,
                ),

                const SizedBox(width: 8),

                Text(
                  activity.date,
                  style: const TextStyle(
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}