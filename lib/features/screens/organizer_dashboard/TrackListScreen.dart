import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_management_app1/features/common/GenericListScreen.dart'; // ✅ NEW: Create this file
import 'package:event_management_app1/features/screens/organizer_dashboard/TrackDetailScreen.dart';
import 'package:event_management_app1/features/screens/organizer_dashboard/CreateTrackScreen.dart'; // ✅ Your existing create screen
import 'package:flutter/material.dart';

class TrackListScreen extends StatelessWidget {
  final String eventId;
  final String subEventId;

  const TrackListScreen({
    super.key,
    required this.eventId,
    required this.subEventId,
  });

  @override
  Widget build(BuildContext context) {
    final collectionRef = FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .collection('subEvents')
        .doc(subEventId)
        .collection('tracks');

    return GenericListScreen(
      title: 'Tracks',
      collectionRef: collectionRef,
      displayFields: ['trackTitle', 'trackDescription'],
      createScreenBuilder: (ctx) => CreateTrackScreen(
        eventId: eventId,
        subEventId: subEventId,
      ),
      onItemTap: (data, docId) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TrackDetailScreen(
              eventId: eventId,
              subEventId: subEventId,
              trackId: docId,
              trackData: data,
            ),
          ),
        );
      },
    );
  }
}
