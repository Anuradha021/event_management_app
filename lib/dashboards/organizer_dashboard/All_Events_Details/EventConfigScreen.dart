import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/ZoneListScreen.dart';
import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/TrackListScreen.dart';
import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/SessionListScreen.dart';
import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/StallListScreen.dart';

class EventConfigScreen extends StatelessWidget {
  final String eventId;
  const EventConfigScreen({super.key, required this.eventId});

  Widget _buildConfigCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.deepPurple),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
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
          'Configure Event',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildConfigCard(
              icon: Icons.workspaces_outline,
              title: 'Zones',
              description: 'Manage event zones and areas',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ZoneListScreen(eventId: eventId),
                ),
              ),
            ),
            _buildConfigCard(
              icon: Icons.timeline,
              title: 'Tracks',
              description: 'Manage tracks within zones',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TrackListScreen(eventId: eventId),
                ),
              ),
            ),
            _buildConfigCard(
              icon: Icons.schedule,
              title: 'Sessions',
              description: 'Manage event sessions',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SessionListScreen(eventId: eventId),
                ),
              ),
            ),
            _buildConfigCard(
              icon: Icons.storefront,
              title: 'Stalls',
              description: 'Manage vendor stalls',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StallListScreen(eventId: eventId),
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.publish),
                label: const Text('PUBLISH EVENT'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  try {
                    await FirebaseFirestore.instance
                        .collection('events')
                        .doc(eventId)
                        .update({'status': 'published'});
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Event published successfully')),
                    );
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}