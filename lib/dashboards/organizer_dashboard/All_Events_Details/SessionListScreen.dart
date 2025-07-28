import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'SessionDetailScreen.dart';

class SessionListScreen extends StatelessWidget {
  final String eventId;
  final String zoneId;
  final String trackId;

  const SessionListScreen({
    super.key,
    required this.eventId,
    required this.zoneId,
    required this.trackId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sessions')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('events')
            .doc(eventId)
            .collection('zones')
            .doc(zoneId)
            .collection('tracks')
            .doc(trackId)
            .collection('sessions')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching sessions'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final sessions = snapshot.data?.docs ?? [];

          if (sessions.isEmpty) {
            return const Center(child: Text('No sessions available.'));
          }

          return ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final sessionDoc = sessions[index];
              final sessionData = sessionDoc.data() as Map<String, dynamic>;
              final sessionId = sessionDoc.id;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(
                      sessionData['title'] ?? 'Unnamed Session',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Speaker: ${sessionData['speakerName'] ?? 'N/A'}'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SessionDetailScreen(
                            eventId: eventId,
                            zoneId: zoneId,
                            trackId: trackId,
                            sessionId: sessionId,
                            sessionData: sessionData,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
