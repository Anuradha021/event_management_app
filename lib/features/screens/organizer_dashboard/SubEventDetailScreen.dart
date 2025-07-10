import 'package:flutter/material.dart';
import 'TrackListScreen.dart';  // To be created
import 'CreateTrackScreen.dart';  // To be created

class SubEventDetailScreen extends StatelessWidget {
  final String eventId;
  final Map<String, dynamic> subEventData;

  const SubEventDetailScreen({
    super.key,
    required this.eventId,
    required this.subEventData,
  });

  @override
  Widget build(BuildContext context) {
    final subEventId = subEventData['docId'];

    return Scaffold(
      appBar: AppBar(title: Text(subEventData['subEventTitle'] ?? 'Sub-Event Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Title: ${subEventData['subEventTitle']}"),
            const SizedBox(height: 8),
            Text("Type: ${subEventData['subEventType'] ?? ''}"),
            const SizedBox(height: 8),
            Text("Date: ${subEventData['subEventDate'].toDate().toString().split(' ')[0]}"),
            const SizedBox(height: 16),

            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Create Track'),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => CreateTrackScreen(
                    eventId: eventId,
                    subEventId: subEventId,
                  ),
                ));
              },
            ),

            const SizedBox(height: 10),

            ElevatedButton.icon(
              icon: const Icon(Icons.list),
              label: const Text('View Tracks'),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => TrackListScreen(
                    eventId: eventId,
                    subEventId: subEventId,
                  ),
                ));
              },
            ),
          ],
        ),
      ),
    );
  }
}
