import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_management_app1/features/screens/organizer_dashboard/All_Events_Details/CreateSubEventScreen.dart';
import 'package:event_management_app1/features/screens/organizer_dashboard/All_Events_Details/SubEventListScreen.dart';
import 'package:flutter/material.dart';

class EventDetailScreen extends StatelessWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  Future<Map<String, dynamic>?> _fetchEventDetails() async {
    final doc = await FirebaseFirestore.instance.collection('events').doc(eventId).get();
    if (doc.exists) {
      final data = doc.data()!;
      data['docId'] = doc.id; // for sub-events screen
      return data;
    }
    return null;
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    final date = (timestamp as Timestamp).toDate();
    return '${date.day}-${date.month}-${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Event Details')),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchEventDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Event not found.'));
          }

          final event = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event['eventTitle'] ?? 'No Title',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                Text('Date: ${_formatDate(event['eventDate'])}', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),

                Text('Location: ${event['location'] ?? 'Not specified'}', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),

                Text('Status: ${event['status'] ?? 'Unknown'}', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 12),

                const Text('Description:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(event['eventDescription'] ?? 'No Description', style: const TextStyle(fontSize: 15)),
                const SizedBox(height: 20),

                const Text('Organizer Details:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Name: ${event['organizerName'] ?? ''}', style: const TextStyle(fontSize: 15)),
                Text('Email: ${event['organizerEmail'] ?? ''}', style: const TextStyle(fontSize: 15)),
                const Spacer(),
SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Create Sub-Events'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SubEventCreateScreen(eventId: event['docId']),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.list_alt),
                    label: const Text('View Sub-Events'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SubEventListScreen(eventId: event['docId']),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
