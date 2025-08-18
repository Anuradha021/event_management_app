import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/orgnizer_dashboard_all_data/moderator.dart';
import 'package:flutter/material.dart';
import '../../../../services/moderator_service.dart';
import 'moderator_card.dart';

class ModeratorList extends StatelessWidget {
  final String eventId;
  final void Function(Moderator) onEdit;
  final void Function(Moderator) onRemove;

  const ModeratorList({
    super.key,
    required this.eventId,
    required this.onEdit,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Moderator>>(
      stream: ModeratorService.getModeratorsForEvent(eventId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(),
          ));
        }

        final moderators = snapshot.data ?? [];

        if (moderators.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No moderators added'),
                  Text('Add moderators to help manage your event'),
                ],
              ),
            ),
          );
        }

        return Column(
          children: moderators
              .map((moderator) => ModeratorCard(
                    moderator: moderator,
                    onEdit: () => onEdit(moderator),
                    onRemove: () => onRemove(moderator),
                  ))
              .toList(),
        );
      },
    );
  }
}
