import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_management_app1/features/screens/organizer_dashboard/ZoneDetailsScreens.dart';
import 'package:flutter/material.dart';


class ZoneListScreen extends StatelessWidget {
  final String eventId;
  final String subEventId;
  final String trackId;

  const ZoneListScreen({
    super.key,
    required this.eventId,
    required this.subEventId,
    required this.trackId,
  });

  Future<List<Map<String, dynamic>>> _fetchZones() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .collection('subEvents')
        .doc(subEventId)
        .collection('tracks')
        .doc(trackId)
        .collection('zones')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['zoneId'] = doc.id;
      return data;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Zones')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchZones(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final zones = snapshot.data ?? [];

          return Column(
            children: [
              Expanded(
                child: zones.isEmpty
                    ? const Center(child: Text('No Zones Found'))
                    : ListView.builder(
                        itemCount: zones.length,
                        itemBuilder: (context, index) {
                          final zone = zones[index];
                          final String zoneId = zone['zoneId'] ?? '';

                          return Card(
                            margin: const EdgeInsets.all(8),
                            child: ListTile(
                              title: Text(zone['zoneTitle'] ?? 'No Title'),
                              subtitle: Text(zone['zoneDescription'] ?? 'No Description'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ZoneDetailScreen(
                                      eventId: eventId,
                                      subEventId: subEventId,
                                      trackId: trackId,
                                      zoneId: zoneId,
                                      zoneData: zone,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
