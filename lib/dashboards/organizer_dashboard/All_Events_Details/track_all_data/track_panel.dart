import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/track_all_data/track_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../components/widgets/panel_header.dart';
import '../components/widgets/zone_dropdown.dart';
import '../components/widgets/track_list_view.dart';
import '../components/widgets/delete_confirmation_dialog.dart';

class TrackPanelService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<List<Map<String, dynamic>>> loadZones(String eventId) async {
    final snapshot = await _firestore
        .collection('events')
        .doc(eventId)
        .collection('zones')
        .get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  static Stream<QuerySnapshot> getTracksStream(String eventId, String zoneId) {
    return _firestore
        .collection('events')
        .doc(eventId)
        .collection('zones')
        .doc(zoneId)
        .collection('tracks')
        .snapshots();
  }

  static Future<void> createTrack(
    String eventId,
    String zoneId,
    String title,
    String description,
  ) async {
    try {
      await _firestore
          .collection('events')
          .doc(eventId)
          .collection('zones')
          .doc(zoneId)
          .collection('tracks')
          .add({
            'title': title, 
            'description': description,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw Exception('Failed to create track: $e');
    }
  }

  static Future<void> deleteTrack(
    String eventId,
    String zoneId,
    String trackId,
  ) async {
    await _firestore
        .collection('events')
        .doc(eventId)
        .collection('zones')
        .doc(zoneId)
        .collection('tracks')
        .doc(trackId)
        .delete();
  }
}

class TrackPanel extends StatefulWidget {
  final String eventId;

  const TrackPanel({
    super.key,
    required this.eventId,
  });

  @override
  State<TrackPanel> createState() => _TrackPanelState();
}

class _TrackPanelState extends State<TrackPanel> {
  String? _selectedZoneId;
  List<Map<String, dynamic>> _zones = [];

  @override
  void initState() {
    super.initState();
    _loadZones();
  }

  Future<void> _loadZones() async {
    try {
      final zones = await TrackPanelService.loadZones(widget.eventId);
      if (mounted) {
        setState(() {
          _zones = zones;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading zones: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PanelHeader(
                title: 'Event Tracks',
                onCreatePressed: _selectedZoneId != null
                    ? () => _showCreateTrackDialog()
                    : null,
                createTooltip: 'Create Track',
                canCreate: _selectedZoneId != null,
              ),
              const SizedBox(height: 12),
              if (_zones.isNotEmpty)
                ZoneDropdown(
                  selectedZoneId: _selectedZoneId,
                  zones: _zones,
                  onChanged: (zoneId) {
                    setState(() {
                      _selectedZoneId = zoneId;
                    });
                  },
                ),
            ],
          ),
        ),
        Expanded(
          child: _selectedZoneId != null
              ? _buildTracksList()
              : const Center(
                  child: Text('Please select a zone to view tracks'),
                ),
        ),
      ],
    );
  }

  Widget _buildTracksList() {
    String? actualZoneId = _selectedZoneId;
    if (_selectedZoneId == 'default' && _zones.isNotEmpty) {
      actualZoneId = _zones.first['id'];
    }

    if (actualZoneId == null) {
      return const Center(child: Text('No zone selected'));
    }

    return TrackListView(
      tracksStream: TrackPanelService.getTracksStream(widget.eventId, actualZoneId),
      onTrackTap: (trackId, data) => _navigateToTrackDetail(trackId, data, actualZoneId!),
      onTrackEdit: (trackId, data) => _navigateToTrackDetail(trackId, data, actualZoneId!),
      onTrackDelete: (trackId) => _handleDeleteTrack(trackId, actualZoneId!),
    );
  }

  void _navigateToTrackDetail(String trackId, Map<String, dynamic> trackData, String zoneId) {
   
    final fixedData = {
      ...trackData,
      'title': trackData['title'] ?? trackData['name'] ?? 'No Title',
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrackDetailScreen(
          eventId: widget.eventId,
          zoneId: zoneId,
          trackId: trackId,
          trackData: fixedData,
        ),
      ),
    );
  }

  void _handleDeleteTrack(String trackId, String zoneId) {
    DeleteConfirmationDialog.show(
      context,
      itemType: 'Track',
      itemName: 'Track',
      onConfirm: () => TrackPanelService.deleteTrack(widget.eventId, zoneId, trackId),
    );
  }

  void _showCreateTrackDialog() {
    final zone = _zones.firstWhere(
      (z) => z['id'] == _selectedZoneId,
      orElse: () => {'title': 'Unnamed Zone', 'name': 'Unnamed Zone'},
    );

    showDialog(
      context: context,
      builder: (context) => _CreateTrackDialog(
        eventId: widget.eventId,
        zoneId: _selectedZoneId!,
       
        zoneName: zone['title'] ?? zone['name'] ?? 'Unnamed Zone',
      ),
    ).then((_) => _loadZones());
  }
}

class _CreateTrackDialog extends StatefulWidget {
  final String eventId;
  final String zoneId;
  final String zoneName;

  const _CreateTrackDialog({
    required this.eventId,
    required this.zoneId,
    required this.zoneName,
  });

  @override
  State<_CreateTrackDialog> createState() => _CreateTrackDialogState();
}

class _CreateTrackDialogState extends State<_CreateTrackDialog> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Track title is required')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await TrackPanelService.createTrack(
        widget.eventId,
        widget.zoneId,
        _titleController.text.trim(),
        _descController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Track created successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating track: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Create New Track'),
          const SizedBox(height: 4),
          Text(
            'For Zone: ${widget.zoneName}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Track Title *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
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
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleCreate,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create'),
        ),
      ],
    );
  }
}
