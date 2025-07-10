import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_management_app1/features/screens/organizer_dashboard/create_session_screen.dart';
import 'package:flutter/material.dart';

class SessionListScreen extends StatelessWidget {
  final String eventId;
  final String subEventId;

  const SessionListScreen({super.key, required this.eventId, required this.subEventId});

  Future<List<Map<String, dynamic>>> _fetchSessions() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .collection('subEvents')
        .doc(subEventId)
        .collection('sessions')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['docId'] = doc.id;   
      return data;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sessions')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchSessions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final sessions = snapshot.data ?? [];

          return Column(
            children: [
              const SizedBox(height: 10),
              TextButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Create Session'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SessionCreateScreen(
                        eventId: eventId,
                        subEventId: subEventId,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              Expanded(
                child: sessions.isEmpty
                    ? const Center(child: Text('No Sessions Found'))
                    : ListView.builder(
                        itemCount: sessions.length,
                        itemBuilder: (context, index) {
                          final session = sessions[index];
                          final title = session['title']?.toString() ?? 'No Title';
                          final speaker = session['speakerName']?.toString() ?? 'No Speaker';
                          final time = '${session['startTime'] ?? ''} - ${session['endTime'] ?? ''}';
                          final description = session['description'] ?? '';

                          return Card(
                            margin: const EdgeInsets.all(8),
                            child: ListTile(
                              title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Speaker: $speaker'),
                                  Text('Time: $time'),
                                ],
                              ),
                              onTap: () {
                              
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: Text(title),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Speaker: $speaker'),
                                        Text('Time: $time'),
                                        const SizedBox(height: 8),
                                        Text(description),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Close'),
                                      ),
                                    ],
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
