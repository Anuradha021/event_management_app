import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'PublishedEventInfoScreen.dart'; 

class PublishedEventsListScreen extends StatelessWidget {
  const PublishedEventsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Events',style: TextStyle(
      color: Colors.white,         
      fontWeight: FontWeight.bold, 
    ),),
        backgroundColor: const Color(0xFF5E35B1),
        
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('events')
            .where('status', isEqualTo: 'published')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No published events found.'));
          }

          final events = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index].data() as Map<String, dynamic>;
              final docId = events[index].id;

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 10),
                color: const Color(0xFFF3EDFF),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    event['eventTitle'] ?? 'Untitled',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5E35B1),
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text("Date: ${_formatDate(event['eventDate'])}"),
                      Text("Location: ${event['location'] ?? 'N/A'}"),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PublishedEventInfoScreen(eventId: docId),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    final date = (timestamp as Timestamp).toDate();
    return '${date.day}-${date.month}-${date.year}';
  }
}
