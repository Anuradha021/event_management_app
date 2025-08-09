import 'package:flutter/material.dart';

/// A reusable list item card widget
/// Follows Single Responsibility Principle - only handles list item display
class ListItemCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final List<Widget>? additionalInfo;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  const ListItemCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.additionalInfo,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
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
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle),
            if (additionalInfo != null) ...[
              const SizedBox(height: 4),
              ...additionalInfo!,
            ],
          ],
        ),
        trailing: showActions ? Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onEdit != null)
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: onEdit,
                tooltip: 'Edit',
              ),
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: onDelete,
                tooltip: 'Delete',
              ),
          ],
        ) : null,
        onTap: onTap,
      ),
    );
  }
}

/// Specialized list item for zones
class ZoneListItem extends StatelessWidget {
  final Map<String, dynamic> zoneData;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ZoneListItem({
    super.key,
    required this.zoneData,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListItemCard(
      icon: Icons.map,
      iconColor: Colors.deepPurple,
      title: zoneData['title'] ?? 'Unnamed Zone',
      subtitle: zoneData['description'] ?? 'No description',
      onTap: onTap,
      onEdit: onEdit,
      onDelete: onDelete,
    );
  }
}

/// Specialized list item for tracks
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
    return ListItemCard(
      icon: Icons.timeline,
      iconColor: Colors.deepPurple,
      title: trackData['title'] ?? 'Unnamed Track',
      subtitle: trackData['description'] ?? 'No description',
      onTap: onTap,
      onEdit: onEdit,
      onDelete: onDelete,
    );
  }
}

/// Specialized list item for sessions
class SessionListItem extends StatelessWidget {
  final Map<String, dynamic> sessionData;
  final String timeText;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const SessionListItem({
    super.key,
    required this.sessionData,
    required this.timeText,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListItemCard(
      icon: Icons.schedule,
      iconColor: Colors.deepPurple,
      title: sessionData['title'] ?? 'Unnamed Session',
      subtitle: sessionData['speaker'] ?? 'No speaker assigned',
      additionalInfo: [
        Text(
          'Time: $timeText',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        if (sessionData['description'] != null)
          Text(
            sessionData['description'],
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
      ],
      onTap: onTap,
      onEdit: onEdit,
      onDelete: onDelete,
    );
  }
}

/// Specialized list item for stalls
class StallListItem extends StatelessWidget {
  final Map<String, dynamic> stallData;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const StallListItem({
    super.key,
    required this.stallData,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListItemCard(
      icon: Icons.store,
      iconColor: Colors.deepPurple,
      title: stallData['name'] ?? 'Unnamed Stall',
      subtitle: stallData['description'] ?? 'No description',
      onTap: onTap,
      onEdit: onEdit,
      onDelete: onDelete,
    );
  }
}
