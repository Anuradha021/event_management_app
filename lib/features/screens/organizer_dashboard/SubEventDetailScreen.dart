import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_management_app1/features/screens/organizer_dashboard/create_session_screen.dart';
import 'package:flutter/material.dart';

class SubEventDetailScreen extends StatefulWidget {
  final String eventId;
  final Map<String, dynamic> subEventData;

  const SubEventDetailScreen({
    Key? key,
    required this.eventId,
    required this.subEventData,
  }) : super(key: key);

  @override
  State<SubEventDetailScreen> createState() => _SubEventDetailScreenState();
}

class _SubEventDetailScreenState extends State<SubEventDetailScreen> {
  List<Map<String, dynamic>> _sessions = [];

  @override
  void initState() {
    super.initState();
    _fetchSessions();
  }

  Future<void> _fetchSessions() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('events')
        .doc(widget.eventId)
        .collection('subEvents')
        .doc(widget.subEventData['docId'])
        .collection('sessions')
        .get();

    setState(() {
      _sessions = snapshot.docs.map((doc) {
        final data = doc.data();
        data['docId'] = doc.id;
        return data;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final subEvent = widget.subEventData;

    return Scaffold(
      appBar: AppBar(title: const Text('Sub-Event Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text('Title: ${subEvent['subEventTitle'] ?? ''}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Description: ${subEvent['subEventDescription'] ?? ''}'),
            const SizedBox(height: 8),
            Text('Type: ${subEvent['subEventType'] ?? ''}'),
            const SizedBox(height: 8),
            Text('Date: ${_formatDate(subEvent['subEventDate'])}'),
            const SizedBox(height: 8),
            Text('Time: ${subEvent['startTime']} - ${subEvent['endTime']}'),
            const SizedBox(height: 8),
            Text('Venue: ${subEvent['venue'] ?? ''}'),
            const SizedBox(height: 16),

            TextButton.icon(
  icon: const Icon(Icons.add),
  label: const Text('Create Session'),
  onPressed: () async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SessionCreateScreen(
          eventId: widget.eventId,
          subEventId: subEvent['docId'],
        ),
      ),
    );
    if (result == true) _fetchSessions();
  },
),

            const SizedBox(height: 16),

            const Text('Sessions:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            if (_sessions.isEmpty)
              const Text('No sessions found.')
            else
              ..._sessions.map((session) => Card(
                    child: ListTile(
                      title: Text(session['title'] ?? 'No Title'),
                      subtitle: Text(session['speakerName'] ?? 'No Speaker'),

                    ),
                  )),
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      return '${date.day}-${date.month}-${date.year}';
    }
    return 'N/A';
  }
}
