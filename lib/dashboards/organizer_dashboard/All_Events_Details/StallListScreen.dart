import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'StallDetailScreen.dart';
import 'StallCreateScreen.dart';

class StallListScreen extends StatelessWidget {
  final String eventId;
  final String zoneId;
  final String trackId;

  const StallListScreen({
    super.key,
    required this.eventId,
    required this.zoneId,
    required this.trackId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stalls')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('events')
            .doc(eventId)
            .collection('zones')
            .doc(zoneId)
            .collection('tracks')
            .doc(trackId)
            .collection('stalls')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Error fetching stalls'));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final stalls = snapshot.data?.docs ?? [];

          if (stalls.isEmpty) {
            return const Center(child: Text('No stalls available.'));
          }

          return ListView.builder(
            itemCount: stalls.length,
            itemBuilder: (context, index) {
              final stallDoc = stalls[index];
              final stallData = stallDoc.data() as Map<String, dynamic>;
              final stallId = stallDoc.id;

              return ListTile(
                title: Text(stallData['name'] ?? 'Unnamed Stall'),
                subtitle: Text('Owner: ${stallData['ownerName'] ?? 'N/A'}'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StallDetailScreen(
                        eventId: eventId,
                        zoneId: zoneId,
                        trackId: trackId,
                        stallId: stallId,
                        stallData: stallData,
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
              builder: (_) => StallCreateScreen(
                eventId: eventId,
                zoneId: zoneId,
                trackId: trackId,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Create Stall',
      ),
    );
  }
}
