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

  if (data == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Request data not found')),
    );
    return;
  }

  final organizerEmail = data['organizerEmail'];
  final organizerUid = data['organizerUid'];

  if (organizerEmail == null || organizerUid == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Organizer email or UID is missing')),
    );
    return;
  }

  // 1. Update event_requests collection
  await docRef.update({
    'status': 'approved',
    'assignedOrganizerEmail': organizerEmail,
  });

  // 2. Promote user to organizer
  final userSnapshot = await FirebaseFirestore.instance
      .collection('users')
      .where('email', isEqualTo: organizerEmail)
      .get();

  if (userSnapshot.docs.isNotEmpty) {
    final userDocId = userSnapshot.docs.first.id;

    await FirebaseFirestore.instance.collection('users').doc(userDocId).update({
      'isOrganizer': true,
      'assignedEventId': docId,
      'popupShown': false, // Optional: reset popup flag
    });
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('User with email $organizerEmail not found')),
    );
    return;
  }

  // 3. Add to events collection
  await FirebaseFirestore.instance.collection('events').add({
    'eventTitle': data['eventTitle'],
    'eventDescription': data['eventDescription'],
    'organizerName': data['organizerName'],
    'organizerEmail': organizerEmail,
    'organizerUid': organizerUid,
    'assignedOrganizerUid': organizerUid,
    'location': data['location'],
    'eventDate': data['eventDate'],
    'status': 'approved',
    'createdAt': FieldValue.serverTimestamp(),
  });

  // 4. Show success
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Event approved and organizer assigned')),
  );

  // Optional: Navigate back or refresh
  Navigator.of(context).pop();
}
