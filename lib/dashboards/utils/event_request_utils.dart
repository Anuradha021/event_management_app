import 'package:event_management_app1/dashboards/admin/create_event_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void updateFilter(Function(String) setFilter, String filterValue) {
  setFilter(filterValue);
}

void updateSearchQuery(Function(String) setQuery, String query) {
  setQuery(query.toLowerCase());
}

void navigateToCreateEvent(BuildContext context, Map<String, dynamic> requestData) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => CreateEventScreen(requestData: requestData),
    ),
  );
}

Future<void> updateRequestStatus(BuildContext context, String docId, String status) async {
  try {
    await FirebaseFirestore.instance
        .collection('event_requests')
        .doc(docId)
        .update({'status': status});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Request $status successfully')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to update status: $e')),
    );
  }
}

Future<void> assignOrganizerAndApprove(BuildContext context, String docId) async {
  final docRef = FirebaseFirestore.instance.collection('event_requests').doc(docId);
  final snapshot = await docRef.get();
  final data = snapshot.data();
  print('Document data: $data');
  if (data == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Request data not found')),
    );
    return;
  }
   print('organizerUid: ${data['organizerUid']}, organizerEmail: ${data['organizerEmail']}');

  final organizerUid = data['uid'] ?? data['organizerUid'];
  final organizerEmail = data['email'] ?? data['organizerEmail'];

  if (organizerUid == null || organizerEmail == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Missing organizer info in request')),
    );
    return;
  }

  await docRef.update({
    'status': 'approved',
    'assignedOrganizerUid': organizerUid,
    'assignedOrganizerEmail': organizerEmail,
  });

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Organizer assigned & request approved')),
  );
}
