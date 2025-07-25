import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StallDetailScreen extends StatelessWidget {
  final String eventId;
  final String stallId;

  const StallDetailScreen({
    super.key,
    required this.eventId,
    required this.stallId,
  });

  @override
  Widget build(BuildContext context) {
    final stallRef = FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .collection('stalls')
        .doc(stallId);

    return Scaffold(
      appBar: AppBar(title: const Text('Stall Details')),
      body: FutureBuilder<DocumentSnapshot>(
        future: stallRef.get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();

          final data = snapshot.data!.data() as Map<String, dynamic>?;

          if (data == null) return const Text('Stall not found.');

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Stall Name: ${data['name'] ?? 'N/A'}', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text('Description: ${data['description'] ?? 'N/A'}'),
                const SizedBox(height: 8),
                Text('Capacity: ${data['capacity'] ?? 'N/A'}'),
              ],
            ),
          );
        },
      ),
    );
  }
}
