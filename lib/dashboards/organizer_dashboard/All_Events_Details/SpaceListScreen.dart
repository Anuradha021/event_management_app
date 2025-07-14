import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_management_app1/dashboards/organizer_dashboard/common/GenericFormScreen.dart';
import 'package:event_management_app1/dashboards/organizer_dashboard/common/GenericListScreen.dart';
import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/SpaceDetailScreen.dart';  

import 'package:flutter/material.dart';

class SpaceListScreen extends StatelessWidget {
  final String eventId;
  final String subEventId;
  final String trackId;
  final String zoneId;

  const SpaceListScreen({
    super.key,
    required this.eventId,
    required this.subEventId,
    required this.trackId,
    required this.zoneId,
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

    return GenericListScreen(
      title: 'Spaces',
      collectionRef: collectionRef,
      displayFields: ['title', 'description'],
      createScreenBuilder: (ctx) => GenericCreateForm(
        title: 'Create Space',
        collectionRef: collectionRef,
      ),
      onItemTap: (data, docId) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SpaceDetailScreen(   
              eventId: eventId,
              subEventId: subEventId,
              trackId: trackId,
              zoneId: zoneId,
              spaceId: docId,
              spaceData: data,
            ),
          ),
        );
      },
    );
  }
}
