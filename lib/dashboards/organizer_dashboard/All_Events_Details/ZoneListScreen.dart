import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/ZoneDetailsScreens.dart';
import 'package:flutter/material.dart';
import 'ZoneCreateScreen.dart';


class ZoneListScreen extends StatelessWidget {
  final String eventId;

  const ZoneListScreen({Key? key, required this.eventId}) : super(key: key);

  Stream<QuerySnapshot> _getZones() {
    return FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .collection('zones')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zones'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getZones(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading zones.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final zones = snapshot.data!.docs;

          if (zones.isEmpty) {
            return const Center(child: Text('No zones found.'));
          }

          return ListView.builder(
            itemCount: zones.length,
            itemBuilder: (context, index) {
              final zone = zones[index];
              final zoneData = zone.data() as Map<String, dynamic>;

              return ListTile(
                title: Text(zoneData['title'] ?? 'Unnamed Zone'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ZoneDetailScreen(
                        eventId: eventId,
                        zoneId: zone.id,
                        zoneData: zoneData, 
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ZoneCreateScreen(eventId: eventId),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
