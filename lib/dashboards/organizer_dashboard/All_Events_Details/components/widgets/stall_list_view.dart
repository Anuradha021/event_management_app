import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'stall_list_item.dart';

/// Single Responsibility: Handle stall list display with loading and error states
class StallListView extends StatelessWidget {
  final Stream<QuerySnapshot> stallsStream;
  final Function(String stallId, Map<String, dynamic> stallData) onStallTap;
  final Function(String stallId, Map<String, dynamic> stallData) onStallEdit;
  final Function(String stallId) onStallDelete;

  const StallListView({
    super.key,
    required this.stallsStream,
    required this.onStallTap,
    required this.onStallEdit,
    required this.onStallDelete,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: stallsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.store_outlined, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No stalls in this track yet',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Tap the + button to create your first stall',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final stall = snapshot.data!.docs[index];
            final data = stall.data() as Map<String, dynamic>;

            return StallListItem(
              stallData: data,
              onTap: () => onStallTap(stall.id, data),
              onEdit: () => onStallEdit(stall.id, data),
              onDelete: () => onStallDelete(stall.id),
            );
          },
        );
      },
    );
  }
}
