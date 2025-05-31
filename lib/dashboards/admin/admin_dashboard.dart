import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_management_app1/dashboards/admin/create_event_screen.dart';
import 'package:flutter/material.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}
class _AdminDashboardState extends State<AdminDashboard> {
  
  String selectedFilter = 'all';

  Stream<QuerySnapshot> getEventStream() {
    final collection = FirebaseFirestore.instance.collection('events');

    if (selectedFilter == 'all') {
      return collection.orderBy('createdAt', descending: true).snapshots();
    } else {
      return collection
          .where('status', isEqualTo: selectedFilter)
          .orderBy('createdAt', descending: true)
          .snapshots();
    }
  }
 
  Widget _buildFilterButton(String label, String filterValue) {
    final isSelected = selectedFilter == filterValue;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue : Colors.grey[300],
        foregroundColor: isSelected ? Colors.white : Colors.black,
      ),
      onPressed: () {
        setState(() {
          selectedFilter = filterValue;
        });
      },
      child: Text(label),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Requests Review'),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateEventScreen()),
              );
            },
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
            // Search bar
            TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search by event title or applicant name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 15),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFilterChip('All', true),
                _buildFilterChip('Pending', false),
                _buildFilterChip('Approved', false),
                _buildFilterChip('Rejected', false),
              ],
            ),
            const SizedBox(height: 15),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('events').orderBy('createdAt', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No events available.'));
                  }

                  final docs = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final event = docs[index].data() as Map<String, dynamic>;
                      return _buildEventCard(event);
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

  Widget _buildFilterChip(String label, bool isSelected) {
    return Chip(
      label: Text(label),
      backgroundColor: isSelected ? Colors.blue : Colors.grey.shade200,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    Color statusColor = Colors.grey;
    if (event['status'] == 'approved') {
      statusColor = Colors.green;
    } else if (event['status'] == 'pending') {
      statusColor = Colors.orange;
    } else if (event['status'] == 'rejected') {
      statusColor = Colors.red;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    event['title'] ?? '',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
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
            const SizedBox(height: 5),
            if (event['author'] != null)
              Text("by ${event['author']}"),
            const SizedBox(height: 10),
            Text(event['description'] ?? '', style: const TextStyle(color: Colors.black87)),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("📅 ${event['date']?.toDate()?.toLocal()?.toString().split(' ')[0] ?? 'No date'}"),
                Text("📂 ${event['category']}"),
              ],
            ),
            const SizedBox(height: 10),

            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Navigate to review details
                },
                child: const Text('Review Details'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
