import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EventDetailScreen extends StatelessWidget {
  final Map<String, dynamic> event;

  const EventDetailScreen({super.key, required this.event});

  Future<void> _updateStatus(BuildContext context, String newStatus) async {
    try {
      final docId = event['id']; 
      if (docId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document ID missing')),
        );
        return;
      }

      await FirebaseFirestore.instance
          .collection('events')
          .doc(docId)
          .update({'status': newStatus});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Event $newStatus successfully')),
      );

      Navigator.pop(context); // Go back to admin dashboard
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor = Colors.grey;
    if (event['status'] == 'approved') {
      statusColor = Colors.green;
    } else if (event['status'] == 'pending') {
      statusColor = Colors.orange;
    } else if (event['status'] == 'rejected') {
      statusColor = Colors.red;
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Event Details")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(event['title'] ?? '', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    event['status'] ?? '',
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),            
            Text("Date: ${event['date']?.toDate()?.toLocal().toString().split(' ')[0] ?? 'N/A'}"),
            const SizedBox(height: 10),
            Text("Category: ${event['category'] ?? 'N/A'}"),
            const SizedBox(height: 20),
            Text(event['description'] ?? '', style: const TextStyle(fontSize: 16)),

            const SizedBox(height: 30),

            if (event['status'] == 'pending') ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text("Approve"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () => _updateStatus(context, 'approved'),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.close),
                    label: const Text("Reject"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () => _updateStatus(context, 'rejected'),
                  ),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }
}
