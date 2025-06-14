import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_management_app1/dashboards/admin/create_event_screen.dart';
import 'package:event_management_app1/dashboards/admin/event_deatils_screen.dart';
import 'package:event_management_app1/dashboards/admin/filter_chips.dart';
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

  void _navigateToCreateEvent(Map<String, dynamic> requestData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateEventScreen(requestData: requestData),
      ),
    );
  }
 Future<void> _updateRequestStatus(String docId, String status) async {
  await updateRequestStatus(context, docId, status);
}
 Future<void> _assignOrganizerAndApprove(String docId) async {
  await assignOrganizerAndApprove(context, docId);
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Event Requests')),
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
    final organizerEmail = (data['organizerEmail'] ?? '').toString().toLowerCase();
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
          trailing: PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'approve') {
                _assignOrganizerAndApprove(doc.id);
              } else if (value == 'reject') {
                _updateRequestStatus(doc.id, 'rejected');
              } else if (value == 'create_event') {
                _navigateToCreateEvent(data);
              }
              else if (value == 'details') {
              Navigator.push(
              context,
              MaterialPageRoute(
              builder: (context) => EventDetailsScreen(eventData: data),
      ),
    );
  }
},
  itemBuilder: (context) {
  final status = data['status'] ?? 'pending';

  List<PopupMenuEntry<String>> items = [];

  if (status == 'pending') {
    items.add(const PopupMenuItem(
      value: 'approve',
      child: Text('Approve & Assign Organizer'),
    ));
    items.add(const PopupMenuItem(
      value: 'reject',
      child: Text('Reject'),
    ));
  } else if (status == 'approved') {

    items.add(const PopupMenuItem(
      value: 'reject',
      child: Text('Reject'),
    ));
  } else if (status == 'rejected') {
   
    items.add(const PopupMenuItem(
      value: 'approve',
      child: Text('Approve & Assign Organizer'),
    ));
  }
  

  items.add(const PopupMenuItem(
    value: 'create_event',
    child: Text('Create Event'),
  ));
  items.add(const PopupMenuItem(
    value: 'details',
    child: Text('Event Details'),
  ));

  return items;
},

          ),
        ),
      );
    },
  );
}
              ),
            ),
          ],
        ),
      ),
    );
  }
}