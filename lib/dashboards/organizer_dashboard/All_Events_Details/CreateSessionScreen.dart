import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CreateSessionScreen extends StatefulWidget {
  final String eventId;

  // We no longer pass zoneId or trackId via constructor,
  // because user must select them from dropdowns here.
  const CreateSessionScreen({super.key, required this.eventId});

  @override
  State<CreateSessionScreen> createState() => _CreateSessionScreenState();
}

class _CreateSessionScreenState extends State<CreateSessionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sessionTitleController = TextEditingController();
  final _speakerController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<Map<String, dynamic>> _zones = [];
  List<Map<String, dynamic>> _tracks = [];

  String? _selectedZoneId;
  String? _selectedTrackId;

  TimeOfDay? _startTime, _endTime;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchZones();
  }

  Future<void> _fetchZones() async {
    final query = await FirebaseFirestore.instance
        .collection('events')
        .doc(widget.eventId)
        .collection('zones')
        .get();

    setState(() {
      _zones = [
        {'id': '__default__', 'title': 'Default Zone'},
        ...query.docs.map((e) => {'id': e.id, 'title': e['title'] ?? 'No Title'}),
        {'id': '__new__', 'title': '+ Create New Zone'}
      ];
      if (_zones.isNotEmpty) _selectedZoneId = _zones[0]['id'] as String;
      _fetchTracksForZone(_selectedZoneId);
    });
  }

  Future<void> _fetchTracksForZone(String? zoneId) async {
    if (zoneId == null || zoneId == '__new__') {
      setState(() {
        _tracks = [];
        _selectedTrackId = null;
      });
      return;
    }
    if (zoneId == '__default__') {
      // For default zone, set default track manually
      setState(() {
        _tracks = [
          {'id': '__default__', 'title': 'Default Track'},
          {'id': '__new__', 'title': '+ Create New Track'}
        ];
        _selectedTrackId = '__default__';
      });
      return;
    }
    final query = await FirebaseFirestore.instance
        .collection('events')
        .doc(widget.eventId)
        .collection('zones')
        .doc(zoneId)
        .collection('tracks')
        .get();

    setState(() {
      _tracks = [
        {'id': '__default__', 'title': 'Default Track'},
        ...query.docs.map((e) => {'id': e.id, 'title': e['title'] ?? 'No Title'}),
        {'id': '__new__', 'title': '+ Create New Track'}
      ];
      _selectedTrackId = _tracks.isNotEmpty ? _tracks[0]['id'] as String : null;
    });
  }

  Future<String> _getOrCreateDefaultZone() async {
    final coll = FirebaseFirestore.instance.collection('events').doc(widget.eventId).collection('zones');
    final snap = await coll.where('isDefault', isEqualTo: true).limit(1).get();
    if (snap.docs.isNotEmpty) return snap.docs.first.id;
    final doc = await coll.add({'title': 'Default Zone', 'isDefault': true, 'createdAt': Timestamp.now()});
    return doc.id;
  }

  Future<String> _getOrCreateDefaultTrack(String zoneId) async {
    final coll = FirebaseFirestore.instance
        .collection('events')
        .doc(widget.eventId)
        .collection('zones')
        .doc(zoneId)
        .collection('tracks');
    final snap = await coll.where('isDefault', isEqualTo: true).limit(1).get();
    if (snap.docs.isNotEmpty) return snap.docs.first.id;
    final doc = await coll.add({'title': 'Default Track', 'isDefault': true, 'createdAt': Timestamp.now()});
    return doc.id;
  }

  Future<void> _showCreateZoneDialog() async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Zone'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Zone Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection('events')
                    .doc(widget.eventId)
                    .collection('zones')
                    .add({'title': controller.text.trim(), 'createdAt': Timestamp.now()});
                Navigator.pop(context);
                await _fetchZones();
                setState(() {
                  _selectedZoneId = _zones.lastWhere((z) => z['title'] == controller.text.trim())['id'];
                });
                await _fetchTracksForZone(_selectedZoneId);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateTrackDialog(String zoneId) async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Track'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Track Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection('events')
                    .doc(widget.eventId)
                    .collection('zones')
                    .doc(zoneId)
                    .collection('tracks')
                    .add({'title': controller.text.trim(), 'createdAt': Timestamp.now()});
                Navigator.pop(context);
                await _fetchTracksForZone(zoneId);
                setState(() {
                  _selectedTrackId = _tracks.lastWhere((t) => t['title'] == controller.text.trim())['id'];
                });
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) {
      setState(() {
        if (isStart) _startTime = picked;
        else _endTime = picked;
      });
    }
  }

  Future<void> _submitSession() async {
    if (!_formKey.currentState!.validate() || _startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }
    if (_selectedZoneId == null || _selectedTrackId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select Zone and Track')));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      String zoneId = _selectedZoneId!;
      if (zoneId == '__default__') {
        zoneId = await _getOrCreateDefaultZone();
      } else if (zoneId == '__new__') {
        // User must create zone first
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please create a Zone first')));
        setState(() => _isSubmitting = false);
        return;
      }

      String trackId = _selectedTrackId!;
      if (trackId == '__default__') {
        trackId = await _getOrCreateDefaultTrack(zoneId);
      } else if (trackId == '__new__') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please create a Track first')));
        setState(() => _isSubmitting = false);
        return;
      }

      await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .collection('zones')
          .doc(zoneId)
          .collection('tracks')
          .doc(trackId)
          .collection('sessions')
          .add({
        'title': _sessionTitleController.text.trim(),
        'speakerName': _speakerController.text.trim(),
        'description': _descriptionController.text.trim(),
        'startTime': _startTime!.format(context),
        'endTime': _endTime!.format(context),
        'createdAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Session Created')));
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Session')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Select Zone'),
                value: _selectedZoneId,
                items: _zones.map((zone) {
                  return DropdownMenuItem<String>(
                    value: zone['id'] as String,
                    child: Text(zone['title'] as String),
                  );
                }).toList(),
                onChanged: (val) async {
                  if (val == '__new__') {
                    await _showCreateZoneDialog();
                  } else {
                    setState(() {
                      _selectedZoneId = val;
                      _selectedTrackId = null;
                      _tracks = [];
                    });
                    await _fetchTracksForZone(val);
                  }
                },
                validator: (val) => val == null || val == '__new__' ? 'Please select or create a Zone' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Select Track'),
                value: _selectedTrackId,
                items: _tracks.map((track) {
                  return DropdownMenuItem<String>(
                    value: track['id'] as String,
                    child: Text(track['title'] as String),
                  );
                }).toList(),
                onChanged: (val) async {
                  if (val == '__new__' && _selectedZoneId != null && _selectedZoneId != '__new__') {
                    await _showCreateTrackDialog(_selectedZoneId!);
                  } else {
                    setState(() {
                      _selectedTrackId = val;
                    });
                  }
                },
                validator: (val) => val == null || val == '__new__' ? 'Please select or create a Track' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _sessionTitleController,
                decoration: const InputDecoration(labelText: 'Session Title'),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _speakerController,
                decoration: const InputDecoration(labelText: 'Speaker Name'),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              ListTile(
                title: Text(
                    _startTime == null ? 'Pick Start Time' : 'Start Time: ${_startTime!.format(context)}'),
                trailing: const Icon(Icons.access_time),
                onTap: () => _pickTime(true),
              ),
              ListTile(
                title:
                    Text(_endTime == null ? 'Pick End Time' : 'End Time: ${_endTime!.format(context)}'),
                trailing: const Icon(Icons.access_time),
                onTap: () => _pickTime(false),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitSession,
                child: _isSubmitting
                    ? const CircularProgressIndicator()
                    : const Text('Create Session'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
