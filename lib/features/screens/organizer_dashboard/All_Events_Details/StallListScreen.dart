import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_management_app1/features/common/GenericFormScreen.dart';
import 'package:event_management_app1/features/common/GenericListScreen.dart';
import 'package:event_management_app1/features/screens/organizer_dashboard/All_Events_Details/StallDetailScreen.dart';
import 'package:flutter/material.dart';

class StallListScreen extends StatelessWidget {
  final String eventId;
  final String subEventId;
  final String trackId;
  final String zoneId;
  final String spaceId;

  const StallListScreen({
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
        .collection('stalls');

    return GenericListScreen(
      title: 'Stalls',
      collectionRef: collectionRef,
      displayFields: ['title', 'description'],
      createScreenBuilder: (ctx) => GenericCreateForm(
        title: 'Create Stall',
        collectionRef: collectionRef,
      ),
      onItemTap: (data, docId) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => StallDetailScreen(
        stallData: data,
      ),
    ),
  );
},

    );
  }
}
