import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TrackListScreen extends StatelessWidget {
  final String eventId;
  final String subEventId;

  const TrackListScreen({
    super.key,
    required this.eventId,
    required this.subEventId,
  });

  Future<List<Map<String, dynamic>>> _fetchTracks() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .collection('subEvents')
        .doc(subEventId)
        .collection('tracks')
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tracks')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchTracks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final tracks = snapshot.data ?? [];

          return Column(
            children: [
              Expanded(
                child: tracks.isEmpty
                    ? const Center(child: Text('No Tracks Found'))
                    : ListView.builder(
                        itemCount: tracks.length,
                        itemBuilder: (context, index) {
                          final track = tracks[index];
                          return Card(
                            margin: const EdgeInsets.all(8),
                            child: ListTile(
                              title: Text(track['trackTitle'] ?? 'No Title'),
                              subtitle: Text(track['trackDescription'] ?? 'No Description'),
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
