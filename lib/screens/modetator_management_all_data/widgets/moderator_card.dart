import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/orgnizer_dashboard_all_data/moderator.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';


class ModeratorCard extends StatelessWidget {
  final Moderator moderator;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  const ModeratorCard({
    super.key,
    required this.moderator,
    required this.onEdit,
    required this.onRemove,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'accepted':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'declined':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(moderator.userName,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(moderator.userEmail,
                          style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(moderator.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    moderator.status.toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('Permissions:',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: moderator.permissions.map((permission) {
                return Chip(
                  label: Text(permission, style: const TextStyle(fontSize: 12)),
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  side: BorderSide(color: AppTheme.primaryColor.withOpacity(0.3)),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: onEdit, child: const Text('Edit')),
                TextButton(
                  onPressed: onRemove,
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Remove'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
