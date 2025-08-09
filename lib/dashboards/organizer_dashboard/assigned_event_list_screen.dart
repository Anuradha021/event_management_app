import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/event_management_screen.dart';
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
      data['docId'] = doc.id;
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
      appBar: AppBar(
  backgroundColor: Colors.deepPurple,
  iconTheme: const IconThemeData(color: Colors.white),
  elevation: 0,
  centerTitle: true,
  title: const Text(
    'My Assigned Events',
    style: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w600,
    ),
  ),
),
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
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(event['eventTitle']?.toString() ?? event['title']?.toString() ?? 'No Title', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Date: ${_formatDate(event['eventDate'])}"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    if (event['docId'] != null) { 
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EventManagementScreen(eventId: event['docId']),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Event ID is missing')),
      );
    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}