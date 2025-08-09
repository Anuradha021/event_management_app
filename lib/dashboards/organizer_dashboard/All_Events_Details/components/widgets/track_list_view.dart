import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'track_list_item.dart';

/// Single Responsibility: Handle track list display with loading and error states
class TrackListView extends StatelessWidget {
  final Stream<QuerySnapshot> tracksStream;
  final Function(String trackId, Map<String, dynamic> trackData) onTrackTap;
  final Function(String trackId, Map<String, dynamic> trackData) onTrackEdit;
  final Function(String trackId) onTrackDelete;

  const TrackListView({
    super.key,
    required this.tracksStream,
    required this.onTrackTap,
    required this.onTrackEdit,
    required this.onTrackDelete,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: tracksStream,
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
                Icon(Icons.timeline_outlined, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No tracks in this zone yet',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Tap the + button to create your first track',
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
            final track = snapshot.data!.docs[index];
            final data = track.data() as Map<String, dynamic>;

            return TrackListItem(
              trackData: data,
              onTap: () => onTrackTap(track.id, data),
              onEdit: () => onTrackEdit(track.id, data),
              onDelete: () => onTrackDelete(track.id),
            );
          },
        );
      },
    );
  }
}
