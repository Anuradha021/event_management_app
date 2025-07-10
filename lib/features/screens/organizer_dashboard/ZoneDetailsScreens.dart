import 'package:flutter/material.dart';
import 'CreateSpaceScreen.dart';
import 'SpaceListScreen.dart';

class ZoneDetailScreen extends StatelessWidget {
  final String eventId;
  final String subEventId;
  final String trackId;
  final String zoneId;
  final Map<String, dynamic> zoneData;

  const ZoneDetailScreen({
    super.key,
    required this.eventId,
    required this.subEventId,
    required this.trackId,
    required this.zoneId,
    required this.zoneData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Zone Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Title: ${zoneData['zoneTitle'] ?? 'N/A'}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Description: ${zoneData['zoneDescription'] ?? 'N/A'}"),
            const SizedBox(height: 24),

            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Create Space'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreateSpaceScreen(
                      eventId: eventId,
                      subEventId: subEventId,
                      trackId: trackId,
                      zoneId: zoneId,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.view_list),
              label: const Text('View Spaces'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SpaceListScreen(
                      eventId: eventId,
                      subEventId: subEventId,
                      trackId: trackId,
                      zoneId: zoneId,
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
