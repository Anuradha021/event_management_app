import 'package:event_management_app1/dashboards/User_dashboard/user_dashboard_widgets/published_events_header.dart';
import 'package:event_management_app1/dashboards/User_dashboard/user_dashboard_widgets/published_events_list.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class SimpleUserDashboard extends StatefulWidget {
  const SimpleUserDashboard({super.key});

  @override
  State<SimpleUserDashboard> createState() => _SimpleUserDashboardState();
}

class _SimpleUserDashboardState extends State<SimpleUserDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Published Events'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('events').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Error loading events',
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No published events found'),
            );
          }

          final events = snapshot.data!.docs;

          return Column(
            children: [
              PublishedEventsHeader(count: events.length),
              Expanded(
                child: PublishedEventsList(events: events),
              ),
            ],
          );
        },
      ),
    );
  }
}
