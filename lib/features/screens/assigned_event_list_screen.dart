import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_management_app1/features/screens/organizer_dashboard/SubEventListScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AssignedEventListScreen extends StatelessWidget {
  const AssignedEventListScreen({super.key});

  Future<List<Map<String, dynamic>>> _fetchAssignedEvents() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final snapshot = await FirebaseFirestore.instance
        .collection('events')
        .where('assignedOrganizerUid', isEqualTo: user.uid)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['docId'] = doc.id; // Store event document ID
      return data;
    }).toList();
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      return '${date.day}-${date.month}-${date.year}';
    }
    return 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Assigned Events")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchAssignedEvents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No events assigned yet."));
          }

          final events = snapshot.data!;
          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              final eventId = event['docId'];

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(event['eventTitle'] ?? 'No Title'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Date: ${_formatDate(event['eventDate'])}"),
                      const SizedBox(height: 4),
                      Text(event['eventDescription'] ?? 'No Description'),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: TextButton.icon(
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('View Sub-Events'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SubEventListScreen(eventId: eventId),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
