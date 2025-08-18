import 'package:event_management_app1/core/theme/app_theme.dart';
import 'package:event_management_app1/screens/orgnizer_event_all_data/widgets/action_buttons.dart';
import 'package:event_management_app1/screens/orgnizer_event_all_data/widgets/event_detail_card.dart';
import 'package:flutter/material.dart';


class OrganizerEventDetailsScreen extends StatelessWidget {
  final String eventId;
  final Map<String, dynamic> eventData;

  const OrganizerEventDetailsScreen({
    super.key,
    required this.eventId,
    required this.eventData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(eventData['eventTitle'] ?? 'Event Details'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EventDetailCard(eventData: eventData),
            const SizedBox(height: 20),
            ActionButtons(eventId: eventId, eventTitle: eventData['eventTitle'] ?? "Event"),
          ],
        ),
      ),
    );
  }
}
