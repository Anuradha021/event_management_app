import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/zone_all_data/zone_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/widgets/panel_header.dart';
import '../components/widgets/zone_list_view.dart';
import '../components/widgets/delete_confirmation_dialog.dart';

class ZonePanel extends StatelessWidget {
  final String eventId;

  const ZonePanel({
    super.key,
    required this.eventId,
  });


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: PanelHeader(
            title: 'Event Zones',
            onCreatePressed: () => _showCreateZoneDialog(context),
            createTooltip: 'Create Zone',
          ),
        ),
  
        Expanded(
          child: ZoneListView(
            zonesStream: FirebaseFirestore.instance
                .collection('events')
                .doc(eventId)
                .collection('zones')
                .snapshots(),
            onZoneTap: (zoneId, data) => _showZoneDetails(context, zoneId, data),
            onZoneEdit: (zoneId, data) => _showZoneDetails(context, zoneId, data),
            onZoneDelete: (zoneId) => _handleDeleteZone(context, zoneId),
          ),
        ),
      ],
    );
  }

  void _showZoneDetails(BuildContext context, String zoneId, Map<String, dynamic> zoneData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ZoneDetailScreen(
          eventId: eventId,
          zoneId: zoneId,
          zoneData: zoneData,
        ),
      ),
    );
  }

  void _showCreateZoneDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Zone'),
        contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0),
        content: SizedBox(
          width: 300,
          child: Column(
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
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _createZone(context, titleController.text, descController.text),
            child: const Text('Create'),
          ),
        ],
      ),
    ).then((_) {
      titleController.dispose();
      descController.dispose();
    });
  }

  Future<void> _createZone(BuildContext context, String title, String description) async {
    if (title.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Zone name is required')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .collection('zones')
          .add({
        'title': title.trim(),  // Use 'title' field for consistency
        'description': description.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Zone created successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating zone: ${e.toString()}')),
        );
      }
    }
  }

  void _handleDeleteZone(BuildContext context, String zoneId) {
    DeleteConfirmationDialog.show(
      context,
      itemType: 'Zone',
      itemName: 'Zone',
      onConfirm: () => _deleteZone(zoneId),
    );
  }

  Future<void> _deleteZone(String zoneId) async {
    try {
      await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .collection('zones')
          .doc(zoneId)
          .delete();
    } catch (e) {
      // Handle error silently or show snackbar if needed
    }
  }
}