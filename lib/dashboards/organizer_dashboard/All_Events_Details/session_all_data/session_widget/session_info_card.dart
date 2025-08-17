import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SessionInfoCard extends StatelessWidget {
  final String title;
  final String description;
  final String speaker;
  final DateTime startTime;
  final DateTime endTime;

  const SessionInfoCard({
    super.key,
    required this.title,
    required this.description,
    required this.speaker,
    required this.startTime,
    required this.endTime,
  });

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('hh:mm a');
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.schedule, color: Colors.deepPurple),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Speaker: $speaker',
                          style: const TextStyle(fontSize: 16, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text(
                        'Time: ${timeFormat.format(startTime)} - ${timeFormat.format(endTime)}',
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (description.isNotEmpty) ...[
              const Text(
                'Description:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(description, style: const TextStyle(fontSize: 16)),
            ],
          ],
        ),
      ),
    );
  }
}
