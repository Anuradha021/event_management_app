import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/ZoneSelectorScreen.dart';
import 'package:flutter/material.dart';
import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/ZoneCreateScreen.dart';
import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/TrackCreateScreen.dart';
import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/CreateSessionScreen.dart';
import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/StallCreateScreen.dart';
import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/ZoneListScreen.dart';


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

            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add_chart),
                label: const Text('Create Track'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TrackCreateScreen(eventId: eventId, zoneId: '',),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
           
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.list),
                label: const Text('View Tracks'),
                onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ZoneSelectorScreen(eventId: eventId, type: 'track'),
    ),
  );
},

              ),
            ),
            const SizedBox(height: 20),

           
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.meeting_room),
                label: const Text('Create Session'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CreateSessionScreen(eventId: eventId, zoneId: 'zoneId', trackId: 'trackId',),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.list),
                label: const Text('View Sessions'),
                onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ZoneSelectorScreen(eventId: eventId, type: 'session'),
    ),
  );
},

              ),
            ),
            const SizedBox(height: 20),

           
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.storefront),
                label: const Text('Create Stall'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ZoneSelectorScreen(eventId: eventId, type: 'stall'),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.list_alt),
                label: const Text('View Stalls'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ZoneSelectorScreen(eventId: eventId, type: 'stall'),
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
