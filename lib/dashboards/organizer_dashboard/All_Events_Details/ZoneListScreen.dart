import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/ZoneDetailsScreens.dart';
import 'package:flutter/material.dart';
 

class ZoneListScreen extends StatelessWidget {
  final String eventId;

  const ZoneListScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    final zonesRef = FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .collection('zones');

    return Scaffold(
      appBar: AppBar(title: const Text('Zones')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: zonesRef.orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No Zones found'));
          }
          final zones = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: zones.length,
            itemBuilder: (context, index) {
              final zone = zones[index].data();
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  title: Text(
                    zone['title'] ?? 'No Title',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: zone['description'] != null && zone['description'].isNotEmpty
                      ? Text(zone['description'])
                      : null,
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ZoneDetailScreen(
                          eventId: eventId,
                          zoneId: zones[index].id,
                          zoneData: zone,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
