import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../core/widgets/empty_state.dart';
import 'stall_list_item.dart';


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
          return const CompactEmptyState(
            icon: Icons.store_outlined,
            title: 'No stalls yet',
            subtitle: 'Tap + to create your first stall',
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
