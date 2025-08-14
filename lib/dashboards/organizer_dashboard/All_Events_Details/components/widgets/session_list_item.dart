import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SessionListItem extends StatelessWidget {
  final Map<String, dynamic> sessionData;
  final DateTime startTime;
  final DateTime endTime;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const SessionListItem({
    super.key,
    required this.sessionData,
    required this.startTime,
    required this.endTime,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('hh:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.deepPurple.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.schedule, color: Colors.deepPurple),
        ),
        title: Text(
          sessionData['title']?.toString() ?? 'Unnamed Session',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Speaker: ${sessionData['speaker']?.toString() ?? 'Not specified'}'),
            Text('Time: ${timeFormat.format(startTime)} - ${timeFormat.format(endTime)}'),
            if (sessionData['description'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  sessionData['description'],
                  style: const TextStyle(fontSize: 12),
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onEdit != null)
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: onEdit,
                tooltip: 'Edit Session',
              ),
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: onDelete,
                tooltip: 'Delete Session',
              ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
