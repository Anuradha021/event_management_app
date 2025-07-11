import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_management_app1/features/common/GenericFormScreen.dart';
import 'package:event_management_app1/features/screens/organizer_dashboard/TrackListScreen.dart';
import 'package:flutter/material.dart';

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

    final collectionRef = FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .collection('subEvents')
        .doc(subEventId)
        .collection('tracks');

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
                  builder: (_) => GenericCreateForm(
                    title: 'Create Track',
                    collectionRef: collectionRef,
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
