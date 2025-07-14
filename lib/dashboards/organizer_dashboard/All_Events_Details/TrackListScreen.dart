import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_management_app1/dashboards/organizer_dashboard/common/GenericFormScreen.dart';
import 'package:event_management_app1/dashboards/organizer_dashboard/common/GenericListScreen.dart';
import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/TrackDetailScreen.dart';
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
      displayFields: ['title', 'description'],  
      createScreenBuilder: (ctx) => GenericCreateForm(   
        title: 'Create Track',
        collectionRef: collectionRef,
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
