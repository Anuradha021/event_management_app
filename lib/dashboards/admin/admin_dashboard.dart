import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_management_app1/dashboards/admin/create_event_screen.dart';
import 'package:event_management_app1/dashboards/admin/event_deatils_screen.dart';
import 'package:event_management_app1/widgets/event_card_widget.dart';
import 'package:event_management_app1/widgets/filter_chip_widget.dart';
import 'package:event_management_app1/widgets/search_bar_widget.dart';
import 'package:flutter/material.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String selectedFilter = 'all';
  String searchQuery = '';

  Stream<QuerySnapshot> getEventStream() {
    try {
      final collection = FirebaseFirestore.instance.collection('events');
      if (selectedFilter == 'all') {
        return collection
            .orderBy('createdAt', descending: true)
            .snapshots(includeMetadataChanges: true);
      } else {
        return collection
            .where('status', isEqualTo: selectedFilter)
            .orderBy('createdAt', descending: true)
            .snapshots(includeMetadataChanges: true);
      }
    } catch (e) {
      debugPrint('Error in getEventStream: $e');
      return const Stream<QuerySnapshot>.empty();
    }
  }

  void _navigateToCreateEvent() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateEventScreen()),
    );
  }

  void _updateFilter(String filterValue) {
    setState(() => selectedFilter = filterValue);
  }

  void _updateSearchQuery(String query) {
    setState(() => searchQuery = query.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Requests Review'),
        actions: [
          TextButton.icon(
            onPressed: _navigateToCreateEvent,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Create Event', style: TextStyle(color: Colors.white)),
            style: TextButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 15),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            SearchBarWidget(onChanged: _updateSearchQuery),
            const SizedBox(height: 15),
            FilterChipsRow(
              selectedFilter: selectedFilter,
              onFilterChanged: _updateFilter,
            ),
            const SizedBox(height: 15),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: getEventStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    debugPrint('Stream error: ${snapshot.error}');
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No events available.'));
                  }

                  final filteredDocs = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final title = data['title']?.toString().toLowerCase() ?? '';
                    final author = data['author']?.toString().toLowerCase() ?? '';
                    return title.contains(searchQuery) || author.contains(searchQuery);
                  }).toList();

                  return ListView.builder(
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      final eventData = filteredDocs[index].data() as Map<String, dynamic>;
                      final eventId = filteredDocs[index].id;
                      return EventCard(
                        event: eventData,
                        eventId: eventId,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EventDetailScreen(event: {...eventData, 'id': eventId}),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
