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
              // Directly open TrackListScreen; zone-selection dropdown lives inside it
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TrackListScreen(eventId: eventId, ),
                ),
              );
            }),
            _buildNavigationButton(context, 'Sessions', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SessionListScreen(eventId: eventId,),
                ),
              );
            }),
            // _buildNavigationButton(context, 'Stalls', () {
            //   Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //       builder: (_) => StallListScreen(eventId: eventId),
            //     ),
            //   );
            // }),
          ],
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
