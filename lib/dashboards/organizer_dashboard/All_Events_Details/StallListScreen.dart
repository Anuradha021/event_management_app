import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'StallDetailScreen.dart';

class StallListScreen extends StatelessWidget {
  final String eventId;

  const StallListScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stalls List')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('events')
            .doc(eventId)
            .collection('stalls')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final stalls = snapshot.data!.docs;

          if (stalls.isEmpty) return const Center(child: Text('No stalls added yet.'));

          return ListView.builder(
            itemCount: stalls.length,
            itemBuilder: (context, index) {
              final stall = stalls[index];
              return ListTile(
                title: Text(stall['name'] ?? 'Unnamed Stall'),
                subtitle: Text('ID: ${stall.id}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StallDetailScreen(
                        eventId: eventId,
                        stallId: stall.id,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),

      // 🔽 Add FAB to directly create stall
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateStallDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateStallDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Create Stall'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Stall Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection('events')
                    .doc(eventId)
                    .collection('stalls')
                    .add({'name': name});
              }
              Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
