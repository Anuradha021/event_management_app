import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_management_app1/dashboards/admin/create_event_screen.dart';
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
      debugPrint('Error in getEventRequestsStream: $e');
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
  try {
    await FirebaseFirestore.instance
        .collection('event_requests')
        .doc(docId)
        .update({'status': status});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Request $status successfully')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to update status: $e')),
    );
  }
}


  Future<void> _assignOrganizerAndApprove(String docId) async {
    final docRef = FirebaseFirestore.instance.collection('event_requests').doc(docId);
    final snapshot = await docRef.get();
    final data = snapshot.data();
 print('Document data: $data'); 
    if (data == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request data not found')),
      );
      return;
    }

    final organizerUid = data['uid'] ?? data['organizerUid'];
final organizerEmail = data['email'] ?? data['organizerEmail'];

    if (organizerUid == null || organizerEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing organizer info in request')),
      );
      return;
    }

    await docRef.update({
      'status': 'approved',
      'assignedOrganizerUid': organizerUid,
      'assignedOrganizerEmail': organizerEmail,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Organizer assigned & request approved')),
    );
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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('Pending'),
                    selected: selectedFilter == 'pending',
                    onSelected: (_) => _updateFilter('pending'),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Approved'),
                    selected: selectedFilter == 'approved',
                    onSelected: (_) => _updateFilter('approved'),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Rejected'),
                    selected: selectedFilter == 'rejected',
                    onSelected: (_) => _updateFilter('rejected'),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('All'),
                    selected: selectedFilter == 'all',
                    onSelected: (_) => _updateFilter('all'),
                  ),
                ],
              ),
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
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'approve',
                child: Text('Approve & Assign Organizer'),
              ),
              const PopupMenuItem(
                value: 'reject',
                child: Text('Reject'),
              ),
              const PopupMenuItem(
                value: 'create_event',
                child: Text('Create Event'),
              ),
            ],
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
