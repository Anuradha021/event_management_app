import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TrackCreateScreen extends StatefulWidget {
  final String eventId;
  final String? zoneId; // Optional: preselect a zone if passed

  const TrackCreateScreen({super.key, required this.eventId, this.zoneId});

  @override
  State<TrackCreateScreen> createState() => _TrackCreateScreenState();
}

class _TrackCreateScreenState extends State<TrackCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedZoneId;
  List<Map<String, dynamic>> _zones = [];
  bool _isLoadingZones = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchZones();
  }

  Future<void> _fetchZones() async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .collection('zones')
          .get();

      final zonesList = [
        {'id': '__default__', 'title': 'Default Zone'},
        ...query.docs.map((e) => {'id': e.id, 'title': e['title'] ?? 'No Title'}),
        {'id': '__new__', 'title': '+ Create New Zone'}
      ];

      setState(() {
        _zones = zonesList;
        // Preselect zone only if current one null or invalid
        if (widget.zoneId != null && _zones.any((z) => z['id'] == widget.zoneId)) {
          _selectedZoneId = widget.zoneId;
        } else if (_zones.isNotEmpty) {
          _selectedZoneId = _zones[0]['id'] as String;
        }
        _isLoadingZones = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingZones = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load zones: $e')));
    }
  }

  Future<String> _getOrCreateDefaultZone() async {
    final coll =
        FirebaseFirestore.instance.collection('events').doc(widget.eventId).collection('zones');

    final snap = await coll.where('isDefault', isEqualTo: true).limit(1).get();
    if (snap.docs.isNotEmpty) return snap.docs.first.id;

    final doc = await coll.add({
      'title': 'Default Zone',
      'isDefault': true,
      'createdAt': Timestamp.now(),
    });
    return doc.id;
  }

  Future<void> _showCreateZoneDialog() async {
    final ctrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Zone'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'Zone Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = ctrl.text.trim();
              if (name.isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection('events')
                    .doc(widget.eventId)
                    .collection('zones')
                    .add({
                  'title': name,
                  'description': '',
                  'createdAt': Timestamp.now(),
                });

                Navigator.pop(context);
                await _fetchZones();

                // Set just created zone as selected
                setState(() {
                  final zone = _zones.firstWhere((z) => z['title'] == name, orElse: () => _zones.first);
                  _selectedZoneId = zone['id'] as String;
                });
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitTrack() async {
    if (!_formKey.currentState!.validate() || _selectedZoneId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a Zone and fill details')));
      return;
    }
    if (_selectedZoneId == '__new__') {
      await _showCreateZoneDialog();
      if (_selectedZoneId == '__new__') return; // User cancelled creation
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      String actualZoneId = _selectedZoneId!;
      if (actualZoneId == '__default__') {
        actualZoneId = await _getOrCreateDefaultZone();
      }

      await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .collection('zones')
          .doc(actualZoneId)
          .collection('tracks')
          .add({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'createdAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Track Created')));
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingZones) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Create Track')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedZoneId,
                decoration: const InputDecoration(labelText: 'Select Zone'),
                items: _zones.map((zone) {
                  return DropdownMenuItem<String>(
                    value: zone['id'] as String,
                    child: Text(zone['title'] as String),
                  );
                }).toList(),
                onChanged: (value) async {
                  if (value == '__new__') {
                    await _showCreateZoneDialog();
                  } else {
                    setState(() {
                      _selectedZoneId = value;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value == '__new__') {
                    return 'Please select or create a Zone';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Track Title'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitTrack,
                child: _isSubmitting
                    ? const CircularProgressIndicator()
                    : const Text('Create Track'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
