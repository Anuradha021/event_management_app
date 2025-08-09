import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Base class for all panel widgets
/// Follows Single Responsibility Principle - provides common panel structure
abstract class BasePanel extends StatefulWidget {
  final String eventId;

  const BasePanel({
    super.key,
    required this.eventId,
  });
}

abstract class BasePanelState<T extends BasePanel> extends State<T> {
  bool _isLoading = false;

  /// Abstract methods to be implemented by subclasses
  String get panelTitle;
  IconData get panelIcon;
  String get createButtonTooltip;
  Widget buildContent();
  Future<void> onCreatePressed();

  /// Optional filter widgets
  Widget? buildFilters() => null;

  /// Loading state management
  void setLoading(bool loading) {
    if (mounted) {
      setState(() => _isLoading = loading);
    }
  }

  bool get isLoading => _isLoading;

  /// Show success message
  void showSuccessMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  /// Show error message
  void showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with title and create button
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(panelIcon, color: Colors.deepPurple),
                  const SizedBox(width: 8),
                  Text(
                    panelTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _isLoading ? null : onCreatePressed,
                    tooltip: createButtonTooltip,
                  ),
                ],
              ),
              
              // Filters if provided
              if (buildFilters() != null) ...[
                const SizedBox(height: 16),
                buildFilters()!,
              ],
            ],
          ),
        ),

        // Content area
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : buildContent(),
        ),
      ],
    );
  }
}

/// Base class for panels with zone/track filtering
abstract class FilteredPanel extends BasePanel {
  const FilteredPanel({
    super.key,
    required super.eventId,
  });
}

abstract class FilteredPanelState<T extends FilteredPanel> extends BasePanelState<T> {
  String? _selectedZoneId;
  String? _selectedTrackId;
  List<Map<String, dynamic>> _zones = [];
  List<Map<String, dynamic>> _tracks = [];

  String? get selectedZoneId => _selectedZoneId;
  String? get selectedTrackId => _selectedTrackId;
  List<Map<String, dynamic>> get zones => _zones;
  List<Map<String, dynamic>> get tracks => _tracks;

  @override
  void initState() {
    super.initState();
    _loadZones();
  }

  Future<void> _loadZones() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .collection('zones')
          .get();

      if (mounted) {
        setState(() {
          _zones = snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              'title': data['title'] ?? 'Unnamed Zone',
            };
          }).toList();

          // Set default selections
          _selectedZoneId = 'default';
          _selectedTrackId = 'default';
        });
      }
    } catch (e) {
      showErrorMessage('Error loading zones: ${e.toString()}');
    }
  }

  Future<void> _loadTracks(String zoneId) async {
    if (zoneId == 'default') {
      setState(() {
        _tracks = [];
        _selectedTrackId = 'default';
      });
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .collection('zones')
          .doc(zoneId)
          .collection('tracks')
          .get();

      if (mounted) {
        setState(() {
          _tracks = snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              'title': data['title'] ?? 'Unnamed Track',
            };
          }).toList();

          _selectedTrackId = _tracks.isNotEmpty ? _tracks.first['id'] : null;
        });
      }
    } catch (e) {
      showErrorMessage('Error loading tracks: ${e.toString()}');
    }
  }

  void onZoneChanged(String? zoneId) {
    setState(() {
      _selectedZoneId = zoneId;
      _selectedTrackId = null;
      _tracks.clear();
    });
    if (zoneId != null) {
      _loadTracks(zoneId);
    }
  }

  void onTrackChanged(String? trackId) {
    setState(() {
      _selectedTrackId = trackId;
    });
  }

  @override
  Widget? buildFilters() {
    return Row(
      children: [
        Expanded(
          child: DropdownButton<String>(
            value: _selectedZoneId,
            hint: const Text('Select Zone'),
            isExpanded: true,
            items: [
              const DropdownMenuItem<String>(
                value: 'default',
                child: Text('Default Zone'),
              ),
              ..._zones.map((zone) {
                return DropdownMenuItem<String>(
                  value: zone['id'],
                  child: Text(zone['title']),
                );
              }),
            ],
            onChanged: onZoneChanged,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: DropdownButton<String>(
            value: _selectedTrackId,
            hint: const Text('Select Track'),
            isExpanded: true,
            items: [
              const DropdownMenuItem<String>(
                value: 'default',
                child: Text('Default Track'),
              ),
              ..._tracks.map((track) {
                return DropdownMenuItem<String>(
                  value: track['id'],
                  child: Text(track['title']),
                );
              }),
            ],
            onChanged: onTrackChanged,
          ),
        ),
      ],
    );
  }
}
