import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_management_app1/dashboards/organizer_dashboard/common/GenericFormScreen.dart';
import 'package:event_management_app1/dashboards/organizer_dashboard/common/GenericListScreen.dart';
import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/ZoneDetailsScreens.dart';

import 'package:flutter/material.dart';

class ZoneListScreen extends StatelessWidget {
  final String eventId;
  final String subEventId;
  final String trackId;

  const ZoneListScreen({
    super.key,
    required this.eventId,
    required this.subEventId,
    required this.trackId,
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

    return GenericListScreen(
      title: 'Zones',
      collectionRef: collectionRef,
      displayFields: ['title', 'description'],
      createScreenBuilder: (ctx) => GenericCreateForm(
        title: 'Create Zone',
        collectionRef: collectionRef,
      ),
      onItemTap: (data, docId) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ZoneDetailScreen(   
              eventId: eventId,
              subEventId: subEventId,
              trackId: trackId,
              zoneId: docId,
              zoneData: data,
            ),
          ),
        );
      },
    );
  }
}
