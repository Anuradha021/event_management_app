import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class EventDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> eventData;

  const EventDetailsScreen({Key? key, required this.eventData}) : super(key: key);

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {

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
    final data = widget.eventData;

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
            Text('Status: ${data['status'] ?? 'N/A'}'),
            const SizedBox(height: 10),
            Text('Description:'),
            Text(data['eventDescription'] ?? 'No Description'),
          ],
        ),
      ),
    );
  }
}
