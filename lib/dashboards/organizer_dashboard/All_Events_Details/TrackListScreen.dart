import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'TrackDetailScreen.dart';

class TrackListScreen extends StatelessWidget {
  final String eventId;
  final String zoneId;

  const TrackListScreen({
    super.key,
    required this.eventId,
    required this.zoneId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tracks")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('events')
            .doc(eventId)
            .collection('zones')
            .doc(zoneId)
            .collection('tracks')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No tracks available."));
          }

          final tracks = snapshot.data!.docs;

          return ListView.builder(
            itemCount: tracks.length,
            itemBuilder: (context, index) {
              final track = tracks[index];
              final data = track.data() as Map<String, dynamic>;
              final title = data['title'] ?? 'No Title';
              final description = data['description'] ?? 'No description';

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(description),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TrackDetailScreen(
                          eventId: eventId,
                          zoneId: zoneId,
                          trackId: track.id,
                          trackData: data,
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
