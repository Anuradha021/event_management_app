import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_management_app1/features/common/GenericListScreen.dart';
import 'package:event_management_app1/features/screens/organizer_dashboard/CreateSessionScreen.dart';
import 'package:event_management_app1/features/screens/organizer_dashboard/SessionDetailScreen.dart';
import 'package:flutter/material.dart';

class SessionListScreen extends StatelessWidget {
  final String eventId;
  final String subEventId;
  final String trackId;
  final String zoneId;
  final String spaceId;

  const SessionListScreen({
    super.key,
    required this.eventId,
    required this.subEventId,
    required this.trackId,
    required this.zoneId,
    required this.spaceId,
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
        .collection('spaces')
        .doc(spaceId)
        .collection('sessions');

    return GenericListScreen(
      title: 'Sessions',
      collectionRef: collectionRef,
      displayFields: ['title', 'speakerName'],
      createScreenBuilder: (ctx) => CreateSessionScreen(
        eventId: eventId,
        subEventId: subEventId,
        trackId: trackId,
        zoneId: zoneId,
        spaceId: spaceId,
      ),
      onItemTap: (data, docId) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SessionDetailScreen(
              eventId: eventId,
              subEventId: subEventId,
              trackId: trackId,
              zoneId: zoneId,
              spaceId: spaceId,
              sessionId: docId,
              sessionData: data,
            ),
          ),
        );
      },
    );
  }
}
