import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SessionListScreen extends StatelessWidget {
  final String eventId;
  final String subEventId;
  final String trackId;
  final String zoneId;
  final String spaceId;

  const SessionListScreen({
    super.key,
    required this.eventId,
    required this.subEventId,
    required this.trackId,
    required this.zoneId,
    required this.spaceId,
  });

  Future<List<Map<String, dynamic>>> _fetchSessions() async {
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
        .doc(spaceId)
        .collection('sessions')
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sessions/Stalls')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchSessions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final sessions = snapshot.data ?? [];

          return Column(
            children: [
              Expanded(
                child: sessions.isEmpty
                    ? const Center(child: Text('No Sessions Found'))
                    : ListView.builder(
                        itemCount: sessions.length,
                        itemBuilder: (context, index) {
                          final session = sessions[index];
                          return Card(
                            margin: const EdgeInsets.all(8),
                            child: ListTile(
                              title: Text(session['title'] ?? 'No Title'),
                              subtitle: Text(session['speakerName'] ?? 'No Speaker'),
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
