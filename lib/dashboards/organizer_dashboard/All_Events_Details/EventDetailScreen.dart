import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_management_app1/dashboards/organizer_dashboard/CreateTickitScreen.dart';
import 'package:event_management_app1/dashboards/organizer_dashboard/TickitListScreen.dart';

import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/ZoneListScreen.dart';
import 'package:event_management_app1/dashboards/organizer_dashboard/common/GenericFormScreen.dart';

import 'package:flutter/material.dart';

// Import the new EventConfigScreen
import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/EventConfigScreen.dart'; // <--- ADD THIS LINE

class EventDetailScreen extends StatelessWidget {
  final String eventId;
  const EventDetailScreen({super.key, required this.eventId});

  Future<Map<String, dynamic>?> _fetchEventDetails() async {
    final doc = await FirebaseFirestore.instance.collection('events').doc(eventId).get();
    if (doc.exists) {
      final data = doc.data()!;
      data['docId'] = doc.id;
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

                // Add the Configuration button here
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.settings),
                    label: const Text('Configuration'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EventConfigScreen(eventId: event['docId']),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),

                
              
                
                // SizedBox(
                //   width: double.infinity,
                //   child: ElevatedButton.icon(
                //     icon: const Icon(Icons.confirmation_number),
                //     label: const Text('Create Tickets'),
                //     onPressed: () {
                //       Navigator.push(
                //         context,
                //         MaterialPageRoute(
                //           builder: (_) => CreateTicketScreen(eventId: event['docId']),
                //         ),
                //       );
                //     },
                //   ),
                // ),
                const SizedBox(height: 12),
                // SizedBox(
                //   width: double.infinity,
                //   child: ElevatedButton.icon(
                //     icon: const Icon(Icons.view_list),
                //     label: const Text('View Tickets'),
                //     onPressed: () {
                //       Navigator.push(
                //         context,
                //         MaterialPageRoute(
                //           builder: (_) => TicketListScreen(eventId: event['docId']),
                //         ),
                //       );
                //     },
                //   ),
                // ),
              ],
            ),
          );
        },
      ),
    );
  }
}
