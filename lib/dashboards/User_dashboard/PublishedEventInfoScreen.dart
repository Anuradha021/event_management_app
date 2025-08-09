import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PublishedEventInfoScreen extends StatelessWidget {
  final String eventId;
  const PublishedEventInfoScreen({super.key, required this.eventId});

  Future<Map<String, dynamic>?> _fetchEvent() async {
    final doc = await FirebaseFirestore.instance.collection('events').doc(eventId).get();
    if (doc.exists) return doc.data();
    return null;
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    final date = (timestamp as Timestamp).toDate();
    return '${date.day}-${date.month}-${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  backgroundColor: Colors.deepPurple,
  iconTheme: const IconThemeData(color: Colors.white),
  elevation: 0,
  centerTitle: true,
  title: const Text(
    'Event Info',
    style: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w600,
    ),
  ),
),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchEvent(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Event not found.'));
          }

          final event = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              color: const Color(0xFFF5F3FB),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        event['eventTitle']?.toString() ?? event['title']?.toString() ?? 'No Title',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5E35B1),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _infoRow("Date", _formatDate(event['eventDate'])),
                    _infoRow("Location", event['location'] ?? 'N/A'),
                    _infoRow("Status", event['status'] ?? 'N/A'),
                    const SizedBox(height: 10),
                    const Text(
                      "Description:",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event['eventDescription']?.toString() ?? event['description']?.toString() ?? 'No description provided.',
                      style: const TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
