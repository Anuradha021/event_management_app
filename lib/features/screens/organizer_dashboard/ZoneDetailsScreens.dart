import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_management_app1/features/common/GenericFormScreen.dart';
import 'package:event_management_app1/features/screens/organizer_dashboard/SpaceListScreen.dart';
import 'package:flutter/material.dart';

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
    final collectionRef = FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .collection('subEvents')
        .doc(subEventId)
        .collection('tracks')
        .doc(trackId)
        .collection('zones')
        .doc(zoneId)
        .collection('spaces');

    return Scaffold(
      appBar: AppBar(title: const Text('Zone Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Title: ${zoneData['title'] ?? 'N/A'}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Description: ${zoneData['description'] ?? 'N/A'}"),
            const SizedBox(height: 24),

            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Create Space'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GenericCreateForm(
                      title: 'Create Space',
                      collectionRef: collectionRef,
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
