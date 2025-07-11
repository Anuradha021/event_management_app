import 'package:flutter/material.dart';

class SessionDetailScreen extends StatelessWidget {
  final String eventId;
  final String subEventId;
  final String trackId;
  final String zoneId;
  final String spaceId;
  final String sessionId;
  final Map<String, dynamic> sessionData;

  const SessionDetailScreen({
    super.key,
    required this.eventId,
    required this.subEventId,
    required this.trackId,
    required this.zoneId,
    required this.spaceId,
    required this.sessionId,
    required this.sessionData,
  });

  String _formatTime(dynamic time) {
    return time ?? 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Session Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              sessionData['title'] ?? 'No Title',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Speaker: ${sessionData['speakerName'] ?? 'N/A'}'),
            const SizedBox(height: 10),
            Text('Start Time: ${_formatTime(sessionData['startTime'])}'),
            const SizedBox(height: 10),
            Text('End Time: ${_formatTime(sessionData['endTime'])}'),
            const SizedBox(height: 10),
            Text('Description:', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(sessionData['description'] ?? 'No Description'),
          ],
        ),
      ),
    );
  }
}
