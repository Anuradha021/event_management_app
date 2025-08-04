import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_management_app1/dashboards/User_dashboard/PublishedEventsListScreen.dart';
import 'package:flutter/material.dart';
import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/ZoneListScreen.dart';
import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/TrackListScreen.dart';
import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/SessionListScreen.dart';
import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/StallListScreen.dart';


class EventConfigScreen extends StatelessWidget {
  final String eventId;
  const EventConfigScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configure Event')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildNavigationButton(context, 'Zones', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ZoneListScreen(eventId: eventId),
                  ),
                );
              }),
              _buildNavigationButton(context, 'Tracks', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TrackListScreen(eventId: eventId),
                  ),
                );
              }),
              _buildNavigationButton(context, 'Sessions', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SessionListScreen(eventId: eventId),
                  ),
                );
              }),
              _buildNavigationButton(context, 'Stalls', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StallListScreen(eventId: eventId),
                  ),
                );
              }),
              const Divider(height: 32),
              // _buildNavigationButton(context, '🎟️ Create Ticket (QR)', () {
              //   Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //       builder: (_) => TicketCreateScreen(eventId: eventId),
              //     ),
              //   );
              // }),
              // _buildNavigationButton(context, '📷 Scan Ticket (QR)', () {
              //   Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //       builder: (_) => TicketScannerScreen(eventId: eventId),
              //     ),
              //   );
              // }),
              ElevatedButton.icon(
  onPressed: () async {
    try {
      await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .update({'status': 'published'});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Event published successfully')),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const PublishedEventsListScreen(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(' Error publishing event: $e')),
      );
    }
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.deepPurple,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 5,
  ),
  icon: const Icon(Icons.publish, color: Colors.white),
  label: const Text(
    'Publish Event',
    style: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ),
),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButton(
      BuildContext context, String title, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(onPressed: onPressed, child: Text(title)),
    );
  }
}
