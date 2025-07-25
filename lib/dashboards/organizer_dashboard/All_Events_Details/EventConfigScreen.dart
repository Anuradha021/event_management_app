import 'package:flutter/material.dart';
import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/ZoneCreateScreen.dart';
import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/TrackCreateScreen.dart';
import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/CreateSessionScreen.dart';

// Import your list screens for zones, tracks, and sessions 
import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/ZoneListScreen.dart';
import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/TrackListScreen.dart';
import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/SessionListScreen.dart';

class EventConfigScreen extends StatelessWidget {
  final String eventId;

  const EventConfigScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Event Configuration')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // Create Zone button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Create Zone'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ZoneCreateScreen(eventId: eventId),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            // View Zones button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.list),
                label: const Text('View Zones'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ZoneListScreen(eventId: eventId),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Create Track button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add_chart),
                label: const Text('Create Track'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TrackCreateScreen(eventId: eventId),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            // View Tracks button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.list),
                label: const Text('View Tracks'),
                onPressed: () {
                  // For choosing zone, you can navigate to a zone selection screen or handle accordingly
                  // Here, we assume user chooses zone in ZoneListScreen and then goes to Tracks
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ZoneListScreen(eventId: eventId),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Create Session button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.meeting_room),
                label: const Text('Create Session'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CreateSessionScreen(eventId: eventId),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            // View Sessions button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.list),
                label: const Text('View Sessions'),
                onPressed: () {
                  // Similarly, user needs to choose zone and track first!
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ZoneListScreen(eventId: eventId),
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
