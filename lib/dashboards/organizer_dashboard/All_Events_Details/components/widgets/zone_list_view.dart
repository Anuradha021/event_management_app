import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../core/widgets/empty_state.dart';
import 'zone_list_item.dart';

/// Single Responsibility: Handle zone list display with loading and error states
class ZoneListView extends StatelessWidget {
  final Stream<QuerySnapshot> zonesStream;
  final Function(String zoneId, Map<String, dynamic> zoneData) onZoneTap;
  final Function(String zoneId, Map<String, dynamic> zoneData) onZoneEdit;
  final Function(String zoneId) onZoneDelete;

  const ZoneListView({
    super.key,
    required this.zonesStream,
    required this.onZoneTap,
    required this.onZoneEdit,
    required this.onZoneDelete,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: zonesStream,
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
            icon: Icons.map_outlined,
            title: 'No zones yet',
            subtitle: 'Tap + to create your first zone',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final zone = snapshot.data!.docs[index];
            final data = zone.data() as Map<String, dynamic>;

            return ZoneListItem(
              zoneData: data,
              onTap: () => onZoneTap(zone.id, data),
              onEdit: () => onZoneEdit(zone.id, data),
              onDelete: () => onZoneDelete(zone.id),
            );
          },
        );
      },
    );
  }
}
