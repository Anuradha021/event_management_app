import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_management_app1/features/common/GenericFormScreen.dart';
import 'package:event_management_app1/features/screens/organizer_dashboard/All_Events_Details/CreateSessionScreen.dart';
import 'package:event_management_app1/features/screens/organizer_dashboard/All_Events_Details/SessionListScreen.dart';
import 'package:event_management_app1/features/screens/organizer_dashboard/All_Events_Details/StallListScreen.dart';
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
            const SizedBox(height: 12),
            ElevatedButton.icon(
  icon: const Icon(Icons.add_business),
  label: const Text('Create Stall'),
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GenericCreateForm(
          title: 'Create Stall',
          collectionRef: FirebaseFirestore.instance
              .collection('events')
              .doc(eventId)
              .collection('subEvents')
              .doc(subEventId)
              .collection('tracks')
              .doc(trackId)
              .collection('zones')
              .doc(zoneId)
              .collection('spaces')
              .doc(spaceId)
              .collection('stalls'),
        ),
      ),
    );
  },
),
const SizedBox(height: 10),
ElevatedButton.icon(
  icon: const Icon(Icons.store),
  label: const Text('View Stalls'),
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StallListScreen(
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
