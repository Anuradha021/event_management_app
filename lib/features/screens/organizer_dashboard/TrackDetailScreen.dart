import 'package:flutter/material.dart';
import 'CreateZoneScreen.dart';
import 'ZoneListScreen.dart';

class TrackDetailScreen extends StatelessWidget {
  final String eventId;
  final String subEventId;
  final String trackId;
  final Map<String, dynamic> trackData;

  const TrackDetailScreen({
    super.key,
    required this.eventId,
    required this.subEventId,
    required this.trackId,
    required this.trackData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Track Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Title: ${trackData['trackTitle'] ?? 'N/A'}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Description: ${trackData['trackDescription'] ?? 'N/A'}"),
            const SizedBox(height: 24),

            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Create Zone'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreateZoneScreen(
                      eventId: eventId,
                      subEventId: subEventId,
                      trackId: trackId,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.view_list),
              label: const Text('View Zones'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ZoneListScreen(
                      eventId: eventId,
                      subEventId: subEventId,
                      trackId: trackId,
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
