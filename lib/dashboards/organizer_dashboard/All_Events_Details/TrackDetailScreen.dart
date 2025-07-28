import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/CreateSessionScreen.dart';
import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/SessionListScreen.dart';

class TrackDetailScreen extends StatelessWidget {
  final String eventId;
  final String zoneId;
  final String trackId;
  final Map trackData;

  const TrackDetailScreen({
    super.key,
    required this.eventId,
    required this.zoneId,
    required this.trackId,
    required this.trackData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Track Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              trackData['title'] ?? 'No Title',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              trackData['description'] ?? 'No Description',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Create Session'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CreateSessionScreen(
                        eventId: eventId,
                        zoneId: zoneId,
                        trackId: trackId,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.list),
                label: const Text('View Sessions'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SessionListScreen(
                        eventId: eventId,
                        zoneId: zoneId,
                        trackId: trackId,
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
