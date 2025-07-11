import 'package:event_management_app1/features/screens/organizer_dashboard/CreateSessionScreen.dart';
import 'package:event_management_app1/features/screens/organizer_dashboard/SessionListScreen.dart';
import 'package:flutter/material.dart';

class SpaceDetailScreen extends StatelessWidget {
  final String eventId;
  final String subEventId;
  final String trackId;
  final String zoneId;
  final String spaceId;
  final Map<String, dynamic> spaceData;

  const SpaceDetailScreen({
    super.key,
    required this.eventId,
    required this.subEventId,
    required this.trackId,
    required this.zoneId,
    required this.spaceId,
    required this.spaceData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Space Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              spaceData['title'] ?? 'No Title',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              spaceData['description'] ?? 'No Description',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Create Session'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreateSessionScreen(
                      eventId: eventId,
                      subEventId: subEventId,
                      trackId: trackId,
                      zoneId: zoneId,
                      spaceId: spaceId,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.list),
              label: const Text('View Sessions'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SessionListScreen(
                      eventId: eventId,
                      subEventId: subEventId,
                      trackId: trackId,
                      zoneId: zoneId,
                      spaceId: spaceId,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
