import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/event_widgets/session_form.dart';
import 'package:flutter/material.dart';
class CreateSessionScreen extends StatelessWidget {
  final String eventId;
  final String? zoneId;
  final String? trackId;

  const CreateSessionScreen({
    super.key,
    required this.eventId,
    this.zoneId,
    this.trackId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
  backgroundColor: Colors.deepPurple,
  iconTheme: const IconThemeData(color: Colors.white),
  elevation: 0,
  centerTitle: true,
  title: const Text(
    'Create Session',
    style: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w600,
    ),
  ),
),

      body: SessionForm(
        eventId: eventId,
        zoneId: zoneId,
        trackId: trackId,
      ),
    );
  }
}
       