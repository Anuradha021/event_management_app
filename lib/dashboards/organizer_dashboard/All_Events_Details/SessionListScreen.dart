import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'CreateSessionScreen.dart'; // Adjust import path accordingly
import 'SessionDetailScreen.dart'; // Adjust import path accordingly

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
    final sessionsRef = FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .collection('zones')
        .doc(zoneId)
        .collection('tracks')
        .doc(trackId)
        .collection('sessions');

    return Scaffold(
      appBar: AppBar(title: const Text('Sessions')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: sessionsRef.orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No Sessions found'));
          }
          final sessions = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index].data();
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  title: Text(
                    session['title'] ?? 'No Title',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: session['speakerName'] != null && session['speakerName'].isNotEmpty
                      ? Text(session['speakerName'])
                      : null,
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SessionDetailScreen(
                          eventId: eventId,
                          zoneId: zoneId,
                          trackId: trackId,
                          sessionId: sessions[index].id,
                          sessionData: session,
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
      floatingActionButton: FloatingActionButton(
        tooltip: 'Create Session',
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreateSessionScreen(eventId: eventId),
            ),
          );
        },
      ),
    );
  }
}
