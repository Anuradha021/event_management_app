import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_management_app1/features/common/GenericFormScreen.dart';
import 'package:event_management_app1/features/screens/organizer_dashboard/ZoneListScreen.dart';
import 'package:flutter/material.dart';

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
    final collectionRef = FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .collection('subEvents')
        .doc(subEventId)
        .collection('tracks')
        .doc(trackId)
        .collection('zones');

    return Scaffold(
      appBar: AppBar(title: const Text('Track Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Title: ${trackData['title'] ?? 'N/A'}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Description: ${trackData['description'] ?? 'N/A'}"),
            const SizedBox(height: 24),

            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Create Zone'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GenericCreateForm(
                      title: 'Create Zone',
                      collectionRef: collectionRef,
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
