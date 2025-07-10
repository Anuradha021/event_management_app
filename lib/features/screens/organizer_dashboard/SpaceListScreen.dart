import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_management_app1/features/screens/organizer_dashboard/SpaceDetailScreen.dart';
import 'package:flutter/material.dart';


class SpaceListScreen extends StatelessWidget {
  final String eventId;
  final String subEventId;
  final String trackId;
  final String zoneId;

  const SpaceListScreen({
    super.key,
    required this.eventId,
    required this.subEventId,
    required this.trackId,
    required this.zoneId,
  });

  Future<List<Map<String, dynamic>>> _fetchSpaces() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .collection('subEvents')
        .doc(subEventId)
        .collection('tracks')
        .doc(trackId)
        .collection('zones')
        .doc(zoneId)
        .collection('spaces')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id; // save space ID
      return data;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Spaces')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchSpaces(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final spaces = snapshot.data ?? [];

          return spaces.isEmpty
              ? const Center(child: Text('No Spaces Found'))
              : ListView.builder(
                  itemCount: spaces.length,
                  itemBuilder: (context, index) {
                    final space = spaces[index];

                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(space['spaceTitle'] ?? 'No Title'),
                        subtitle: Text(space['spaceDescription'] ?? 'No Description'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SpaceDetailScreen(
                                eventId: eventId,
                                subEventId: subEventId,
                                trackId: trackId,
                                zoneId: zoneId,
                                spaceId: space['id'],
                                spaceData: space,
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
