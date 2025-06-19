import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_management_app1/dashboards/admin/create_event_screen.dart';
import 'package:event_management_app1/dashboards/admin/event_deatils_screen.dart';
import 'package:event_management_app1/dashboards/admin/filter_chips.dart';
import 'package:event_management_app1/dashboards/admin/user_list_screen.dart';
import 'package:event_management_app1/dashboards/utils/event_request_utils.dart';
import 'package:flutter/material.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String selectedFilter = 'pending';
  String searchQuery = '';

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
  title: const Text('Event Requests'),
  actions: [
   Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white, 
          foregroundColor: Colors.black,  
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          elevation: 3,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateEventScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text(
          'Create Event',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    ),
    IconButton(
      icon: const Icon(Icons.manage_accounts),
      tooltip: 'Manage Users',
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const UserListScreen()),
        );
      },
    ),
  ],
),

      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search requests...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: _updateSearchQuery,
            ),
            const SizedBox(height: 15),
            FilterChips(
              selectedFilter: selectedFilter,
              onFilterSelected: _updateFilter,
            ),
            const SizedBox(height: 15),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
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
                    final organizerEmail =
                        (data['organizerEmail'] ?? '').toString().toLowerCase();
                    return title.contains(searchQuery) || organizerEmail.contains(searchQuery);
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
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EventDetailsScreen(eventData: data, docId: doc.id),
                              ),
                            );
                          },
                        ),
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
