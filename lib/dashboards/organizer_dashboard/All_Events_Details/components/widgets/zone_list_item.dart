import 'package:flutter/material.dart';
import '../../../../../core/widgets/modern_card.dart';
import '../../../../../core/theme/app_theme.dart';


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
    return ModernListCard(
      icon: Icons.map_outlined,
      iconColor: AppTheme.primaryColor,
      title: zoneData['title']?.toString() ?? zoneData['name']?.toString() ?? 'Unnamed Zone',
      subtitle: zoneData['description']?.toString() ?? 'No description',
      onTap: onTap,
      onEdit: onEdit,
      onDelete: onDelete,
      additionalInfo: [
        if (zoneData['createdAt'] != null)
          Text(
            'Created: ${_formatDate(zoneData['createdAt'])}',
            style: AppTheme.bodySmall,
          ),
      ],
    );
  }

  String _formatDate(dynamic timestamp) {
    try {
      if (timestamp == null) return 'Unknown';
      // Handle Firestore Timestamp or DateTime
      DateTime date;
      if (timestamp.runtimeType.toString().contains('Timestamp')) {
        date = timestamp.toDate();
      } else if (timestamp is DateTime) {
        date = timestamp;
      } else {
        return 'Unknown';
      }
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Unknown';
    }
  }
}
