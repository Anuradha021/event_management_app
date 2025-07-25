import 'package:flutter/material.dart';

class SessionDetailScreen extends StatelessWidget {
  final String eventId;
  final String zoneId;
  final String trackId;
  final String sessionId;
  final Map sessionData;

  const SessionDetailScreen({
    super.key,
    required this.eventId,
    required this.zoneId,
    required this.trackId,
    required this.sessionId,
    required this.sessionData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(sessionData['title'] ?? 'Session Details')),
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
            Text('Start Time: ${sessionData['startTime'] ?? 'N/A'}'),
            const SizedBox(height: 10),
            Text('End Time: ${sessionData['endTime'] ?? 'N/A'}'),
            const SizedBox(height: 10),
            const Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(sessionData['description'] ?? 'No Description'),
          ],
        ),
      ),
    );
  }
}
