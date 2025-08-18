import 'package:event_management_app1/core/theme/app_theme.dart';
import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/event_management_screen.dart';
import 'package:event_management_app1/screens/modetator_management_all_data/moderator_management_screen.dart';
import 'package:flutter/material.dart';


class ActionButtons extends StatelessWidget {
  final String eventId;
  final String eventTitle;

  const ActionButtons({
    super.key,
    required this.eventId,
    required this.eventTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EventManagementScreen(eventId: eventId)),
              );
            },
            icon: const Icon(Icons.settings),
            label: const Text("Configure"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ModeratorManagementScreen(
                    eventId: eventId,
                    eventTitle: eventTitle,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.people),
            label: const Text("Moderators"),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
