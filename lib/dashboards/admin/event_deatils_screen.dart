import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_management_app1/dashboards/utils/event_request_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> eventData;
  final String docId;

  const EventDetailsScreen({Key? key, required this.eventData, required this.docId}) : super(key: key);

  String _formatDate(dynamic timestamp) {
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      return DateFormat('dd-MMM-yy').format(date);
    } else {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = eventData;
    final status = data['status'] ?? 'pending';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              data['eventTitle'] ?? 'No Title',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Organizer Email: ${data['organizerEmail'] ?? 'N/A'}'),
            const SizedBox(height: 10),
            Text('Event Date: ${_formatDate(data['eventDate'])}'),
            const SizedBox(height: 10),
            Text('Location: ${data['location'] ?? 'N/A'}'),
            const SizedBox(height: 10),
            Text('Status: $status'),
            const SizedBox(height: 10),
            const Text('Description:'),
            Text(data['eventDescription'] ?? 'No Description'),
            const SizedBox(height: 20),

            if (status == 'pending' || status == 'rejected') ...[
              ElevatedButton(
                onPressed: () {
                  assignOrganizerAndApprove(context, docId);
                },
                child: const Text('Approve & Assign Organizer'),
              ),
              const SizedBox(height: 10),
            ],
            if (status == 'pending' || status == 'approved') ...[
              ElevatedButton(
                onPressed: () {
                  updateRequestStatus(context, docId, 'rejected');
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Reject'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
