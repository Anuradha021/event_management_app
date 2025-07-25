import 'package:flutter/material.dart';
import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/ZoneCreateScreen.dart';
import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/TrackCreateScreen.dart';
import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/StallCreateScreen.dart';
import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/SessionCreateScreen.dart';
// Ensure that the file 'SessionCreateScreen.dart' exists and contains a class named 'SessionCreateScreen'.

class ManageEventComponentsScreen extends StatelessWidget {
  final String eventId;

  const ManageEventComponentsScreen({super.key, required this.eventId});
  
  get zoneId => null;
  
  get trackId => null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Event Components")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildNavCard(context, "Zone", ZoneCreateScreen(eventId: eventId)),
          _buildNavCard(context, "Track", TrackCreateScreen(eventId: eventId)),
         
          _buildNavCard(context, "Stall", StallCreateScreen(eventId: eventId)),
          _buildNavCard(context, "Session", CreateSessionScreen(eventId: eventId , zoneId: zoneId,
      trackId: trackId,)),
        ],
      ),
    );
  }

  Widget _buildNavCard(BuildContext context, String title, Widget screen) {
    return Card(
      child: ListTile(
        title: Text("Create $title"),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
        },
      ),
    );
  }
}
