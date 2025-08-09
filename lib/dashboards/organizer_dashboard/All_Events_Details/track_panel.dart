import 'package:flutter/material.dart';
import 'TrackDetailScreen.dart';
import 'components/services/track_panel_service.dart';
import 'components/widgets/panel_header.dart';
import 'components/widgets/zone_dropdown.dart';
import 'components/widgets/track_list_view.dart';
import 'components/widgets/delete_confirmation_dialog.dart';

/// Refactored Track Panel - Single Responsibility: Coordinate track management components
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
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              PanelHeader(
                title: 'Event Tracks',
                onCreatePressed: _selectedZoneId != null
                    ? () => _showCreateTrackDialog()
                    : null,
                createTooltip: 'Create Track',
                canCreate: _selectedZoneId != null,
              ),
              const SizedBox(height: 16),
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
    // Determine the actual zone ID to use
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrackDetailScreen(
          eventId: widget.eventId,
          zoneId: zoneId,
          trackId: trackId,
          trackData: trackData,
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
    // Determine the actual zone ID to use
    String? actualZoneId = _selectedZoneId;
    if (_selectedZoneId == 'default' && _zones.isNotEmpty) {
      actualZoneId = _zones.first['id'];
    }

    if (actualZoneId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a valid zone first')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => _CreateTrackDialog(
        eventId: widget.eventId,
        zoneId: actualZoneId!,
      ),
    );
  }
}

/// Single Responsibility: Handle track creation dialog
class _CreateTrackDialog extends StatefulWidget {
  final String eventId;
  final String zoneId;

  const _CreateTrackDialog({
    required this.eventId,
    required this.zoneId,
  });

  @override
  State<_CreateTrackDialog> createState() => _CreateTrackDialogState();
}

class _CreateTrackDialogState extends State<_CreateTrackDialog> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Track name is required')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await TrackPanelService.createTrack(
        widget.eventId,
        widget.zoneId,
        _nameController.text.trim(),
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
          SnackBar(content: Text('Error creating track: $e')),
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
      title: const Text('Create New Track'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Track Name *',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descController,
            decoration: const InputDecoration(
              labelText: 'Description (Optional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
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