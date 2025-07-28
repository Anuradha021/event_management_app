import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/TrackListScreen.dart';
import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/TrackCreateScreen.dart';

class ZoneDetailScreen extends StatelessWidget {
  final String eventId;
  final String zoneId;
  final Map zoneData;

  const ZoneDetailScreen({
    super.key,
    required this.eventId,
    required this.zoneId,
    required this.zoneData,
  });

  @override
  Widget build(BuildContext context) {
    // Fallback: if 'zoneName' is expected in other screens, we assign it from 'title'
    final String zoneName = zoneData['title'] ?? zoneData['title'] ?? 'Untitled Zone';

    return Scaffold(
      appBar: AppBar(title: Text('$zoneName Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(zoneName,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(zoneData['description'] ?? 'No Description',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),

            // Create Track
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Create Track'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TrackCreateScreen(
                        eventId: eventId,
                        zoneId: zoneId,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // View Tracks
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.list_alt),
                label: const Text('View Tracks'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TrackListScreen(
                        eventId: eventId,
                        zoneId: zoneId,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
