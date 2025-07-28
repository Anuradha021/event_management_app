import 'package:flutter/material.dart';

class StallDetailScreen extends StatelessWidget {
  final String eventId;
  final String zoneId;
  final String trackId;
  final String stallId;
  final Map stallData;

  const StallDetailScreen({
    super.key,
    required this.eventId,
    required this.zoneId,
    required this.trackId,
    required this.stallId,
    required this.stallData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(stallData['name'] ?? 'Stall Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              stallData['name'] ?? 'No Name',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Owner: ${stallData['ownerName'] ?? 'N/A'}'),
            const SizedBox(height: 10),
            const Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(stallData['description'] ?? 'No Description'),
          ],
        ),
      ),
    );
  }
}
