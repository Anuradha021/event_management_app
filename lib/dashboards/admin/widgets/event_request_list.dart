import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_management_app1/dashboards/admin/event_deatils_screen.dart';
import 'package:flutter/material.dart';
class EventRequestList extends StatelessWidget {
  final String selectedFilter;
  final String searchQuery;

  const EventRequestList({
    super.key,
    required this.selectedFilter,
    required this.searchQuery,
  });

  Stream<QuerySnapshot> getEventRequestsStream() {
    try {
      final collection = FirebaseFirestore.instance.collection('event_requests');
      if (selectedFilter == 'all') {
        return collection.orderBy('createdAt', descending: true).snapshots();
      } else {
        return collection
            .where('status', isEqualTo: selectedFilter)
            .orderBy('createdAt', descending: true)
            .snapshots();
      }
    } catch (e) {
      return const Stream<QuerySnapshot>.empty();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: getEventRequestsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final docs = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final title = (data['eventTitle'] ?? '').toString().toLowerCase();
          final email = (data['organizerEmail'] ?? '').toString().toLowerCase();
          return title.contains(searchQuery) || email.contains(searchQuery);
        }).toList();

        if (docs.isEmpty) {
          return const Center(child: Text('No event requests found.'));
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(data['eventTitle'] ?? 'No title'),
                subtitle: Text('Organizer: ${data['organizerEmail'] ?? 'N/A'}'),
                trailing: Icon(Icons.chevron_right, color: Colors.grey[600]),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventDetailsScreen(
                        eventData: data,
                        docId: doc.id,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
