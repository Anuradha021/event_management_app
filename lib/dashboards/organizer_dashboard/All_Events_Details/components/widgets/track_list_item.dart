import 'package:flutter/material.dart';


class TrackListItem extends StatelessWidget {
  final Map<String, dynamic> trackData;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TrackListItem({
    super.key,
    required this.trackData,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
          child: const Icon(Icons.timeline, color: Colors.deepPurple),
        ),
        title: Text(
          trackData['name']?.toString() ?? 'Unnamed Track',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          trackData['description']?.toString() ?? 'No description',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onEdit != null)
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: onEdit,
                tooltip: 'Edit Track',
              ),
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: onDelete,
                tooltip: 'Delete Track',
              ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
