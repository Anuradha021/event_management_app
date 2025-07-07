import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_management_app1/features/screens/organizer_dashboard/CreateSubEventScreen.dart';
import 'package:event_management_app1/features/screens/organizer_dashboard/SubEventDetailScreen.dart';
import 'package:flutter/material.dart';

class SubEventListScreen extends StatelessWidget {
  final String eventId;

  const SubEventListScreen({super.key, required this.eventId});

  Future<List<Map<String, dynamic>>> _fetchSubEvents() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .collection('subEvents')
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
      appBar: AppBar(title: const Text('Sub-Events')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchSubEvents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final subEvents = snapshot.data ?? [];

          return Column(
            children: [
              TextButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Create Sub-Event'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SubEventCreateScreen(eventId: eventId),
                    ),
                  );
                },
              ),
              Expanded(
                child: subEvents.isEmpty
                    ? const Center(child: Text('No Sub-Events Found'))
                    : ListView.builder(
                        itemCount: subEvents.length,
                        itemBuilder: (context, index) {
                          final subEvent = subEvents[index];
                          return Card(
                            margin: const EdgeInsets.all(8),
                            child: ListTile(
                              title: Text(subEvent['subEventTitle'] ?? 'No Title'),
                              subtitle: Text(subEvent['subEventDescription'] ?? 'No Description'),
                              trailing: const Icon(Icons.arrow_forward),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SubEventDetailScreen(
                                      eventId: eventId,
                                      subEventData: subEvent,
                                    ),
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