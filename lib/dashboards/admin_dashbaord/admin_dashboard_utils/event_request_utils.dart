import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_management_app1/dashboards/admin_dashbaord/create_event_screen.dart';
import 'package:flutter/material.dart';

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

///  Reject Event Request 
Future<void> updateRequestStatus(
    BuildContext context, String docId, String status) async {
  try {
    await FirebaseFirestore.instance
        .collection('event_requests')
        .doc(docId)
        .update({
          'status': status,
          'updatedAt': FieldValue.serverTimestamp(),
        });

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Event request $status successfully.")),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating status: $e")),
      );
    }
  }
}


Future<void> assignOrganizerAndApprove(BuildContext context, String docId) async {
  try {
    // First, get the event request data
    final requestDoc = await FirebaseFirestore.instance
        .collection('event_requests')
        .doc(docId)
        .get();

    if (!requestDoc.exists) {
      throw Exception('Event request not found');
    }

    final requestData = requestDoc.data() as Map<String, dynamic>;
    final organizerEmail = requestData['organizerEmail'] as String;
    final organizerUid = requestData['organizerUid'] as String;

    // Step 1: Update user to be organizer
    await FirebaseFirestore.instance
        .collection('users')
        .doc(organizerUid)
        .update({
          'isOrganizer': true,
        });

    // Step 2: Create approved event in events collection
    final eventRef = await FirebaseFirestore.instance
        .collection('events')
        .add({
          'eventTitle': requestData['eventTitle'],
          'eventDescription': requestData['eventDescription'],
          'eventDate': requestData['eventDate'],
          'location': requestData['location'],
          'organizerUid': organizerUid,
          'organizerEmail': organizerEmail,
          'organizerName': requestData['organizerName'] ?? 'Organizer',
          'assignedOrganizerUid': organizerUid,
          'assignedOrganizerEmail': organizerEmail,
          'status': 'approved',
          'createdAt': FieldValue.serverTimestamp(),
          'approvedAt': FieldValue.serverTimestamp(),
        });

    // Step 3: Update the original request status
    await FirebaseFirestore.instance
        .collection('event_requests')
        .doc(docId)
        .update({
          'status': 'approved',
          'eventId': eventRef.id,
          'approvedAt': FieldValue.serverTimestamp(),
        });

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event approved and organizer assigned successfully!')),
      );
      Navigator.of(context).pop();
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error approving event: $e")),
      );
    }
  }
}
