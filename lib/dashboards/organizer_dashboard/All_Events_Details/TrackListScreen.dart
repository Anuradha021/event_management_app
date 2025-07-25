import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'TrackDetailScreen.dart'; // Adjust import path accordingly

class TrackListScreen extends StatelessWidget {
  final String eventId;
  final String zoneId;

  const TrackListScreen({super.key, required this.eventId, required this.zoneId});

  @override
  Widget build(BuildContext context) {
    final tracksRef = FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .collection('zones')
        .doc(zoneId)
        .collection('tracks');

    return Scaffold(
      appBar: AppBar(title: const Text('Tracks')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: tracksRef.orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No Tracks found'));
          }
          final tracks = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: tracks.length,
            itemBuilder: (context, index) {
              final track = tracks[index].data();
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  title: Text(
                    track['title'] ?? 'No Title',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: track['description'] != null && track['description'].isNotEmpty
                      ? Text(track['description'])
                      : null,
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TrackDetailScreen(
                          eventId: eventId,
                          zoneId: zoneId,
                          trackId: tracks[index].id,
                          trackData: track,
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
