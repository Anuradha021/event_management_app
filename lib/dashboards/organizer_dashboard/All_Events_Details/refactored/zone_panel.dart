import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../shared/base/base_panel.dart';
import '../shared/widgets/list_item_card.dart';
import 'zone_detail_screen.dart';

/// Refactored Zone Panel
/// Follows Single Responsibility Principle - only handles zone list display
class ZonePanel extends BasePanel {
  const ZonePanel({
    super.key,
    required super.eventId,
  });

  @override
  State<ZonePanel> createState() => _ZonePanelState();
}

class _ZonePanelState extends BasePanelState<ZonePanel> {
  @override
  String get panelTitle => 'Event Zones';

  @override
  IconData get panelIcon => Icons.map;

  @override
  String get createButtonTooltip => 'Create Zone';

  @override
  Future<void> onCreatePressed() async {
    await _showCreateZoneDialog();
  }

  @override
  Widget buildContent() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .collection('zones')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No zones created yet'));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final zone = snapshot.data!.docs[index];
            final data = zone.data() as Map<String, dynamic>;

            return ZoneListItem(
              zoneData: data,
              onTap: () => _navigateToZoneDetail(zone.id, data),
              onEdit: () => _navigateToZoneDetail(zone.id, data),
              onDelete: () => _deleteZone(zone.id),
            );
          },
        );
      },
    );
  }

  void _navigateToZoneDetail(String zoneId, Map<String, dynamic> zoneData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ZoneDetailScreen(
          eventId: widget.eventId,
          zoneId: zoneId,
          initialData: zoneData,
        ),
      ),
    );
  }

  Future<void> _deleteZone(String zoneId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Zone'),
        content: const Text('Are you sure you want to delete this zone? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance
            .collection('events')
            .doc(widget.eventId)
            .collection('zones')
            .doc(zoneId)
            .delete();
        showSuccessMessage('Zone deleted successfully');
      } catch (e) {
        showErrorMessage('Error deleting zone: ${e.toString()}');
      }
    }
  }

  Future<void> _showCreateZoneDialog() async {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Zone'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Zone Name *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _createZone(titleController.text, descController.text),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    titleController.dispose();
    descController.dispose();
  }

  Future<void> _createZone(String title, String description) async {
    if (title.trim().isEmpty) {
      showErrorMessage('Zone name is required');
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .collection('zones')
          .add({
        'title': title.trim(),
        'description': description.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context);
        showSuccessMessage('Zone created successfully');
      }
    } catch (e) {
      showErrorMessage('Error creating zone: ${e.toString()}');
    }
  }
}
