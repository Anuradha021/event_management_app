import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/TrackCreateScreen.dart';
import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/ZoneCreateScreen.dart';
import 'package:event_management_app1/dashboards/organizer_dashboard/services/cache_manager.dart';
import 'package:flutter/material.dart';

class CreateSessionScreen extends StatefulWidget {
  final String eventId;
  final String? zoneId;
  final String? trackId;

  const CreateSessionScreen({
    super.key, 
    required this.eventId,
    this.zoneId,
    this.trackId,
  });

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
  bool _isInitializing = true;

 @override
void initState() {
  super.initState();
  _selectedZoneId = widget.zoneId;
  _selectedTrackId = widget.trackId;

  _fetchZones().then((_) async {
    if (_selectedZoneId != null && _selectedZoneId != 'new') {
      await _fetchTracksForZone(_selectedZoneId);
    }
    setState(() => _isInitializing = false);
  });
}

  Future<void> _fetchZones() async {
  final cachedZones = CacheManager().get('zones_${widget.eventId}');
  if (cachedZones != null) {
    print(" Using cached zones");
    setState(() {
      _zones = cachedZones;
    });
    return;
  }
print(" Fetching zones from Firestore...");
  final query = await FirebaseFirestore.instance
      .collection('events')
      .doc(widget.eventId)
      .collection('zones')
      .get();

  final fetchedZones = [
    ...query.docs.map((e) => {'id': e.id, 'title': e['title'] ?? 'No Title'}),
    {'id': 'new', 'title': '+ Create New Zone'}
  ];

  setState(() {
    _zones = fetchedZones;
  });

  CacheManager().save('zones_${widget.eventId}', fetchedZones);
}

  Future<void> _fetchTracksForZone(String? zoneId) async {
  if (zoneId == null || zoneId == 'new') {
    setState(() {
      _tracks = [];
      _selectedTrackId = null;
    });
    return;
  }

  final cacheKey = 'tracks_${widget.eventId}_$zoneId';
  final cachedTracks = CacheManager().get(cacheKey);

  if (cachedTracks != null) {
   
    final updatedTracks = [
      ...cachedTracks.where((t) => t['id'] != 'new'),
      {'id': 'new', 'title': '+ Create New Track'},
    ];
    setState(() {
      _tracks = updatedTracks;
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

  final fetchedTracks = [
    ...query.docs.map((e) => {'id': e.id, 'title': e['title'] ?? 'No Title'}),
    {'id': 'new', 'title': '+ Create New Track'},
  ];

  setState(() {
    _tracks = fetchedTracks;
  });

  CacheManager().save(cacheKey, fetchedTracks);
}


Future<void> _navigateToCreateZoneScreen() async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ZoneCreateScreen(eventId: widget.eventId),
    ),
  );
  CacheManager().clear('zones_${widget.eventId}');
  await _fetchZones();
}

Future<void> _navigateToCreateTrackScreen(String zoneId) async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => TrackCreateScreen(
        eventId: widget.eventId,
        zoneId: zoneId,
      ),
    ),
  );
 CacheManager().clear('tracks_${widget.eventId}_$zoneId');
await _fetchTracksForZone(zoneId);

if (_tracks.isNotEmpty && _tracks.any((t) => t['id'] != 'new')) {
  setState(() {
    _selectedTrackId = _tracks.firstWhere((t) => t['id'] != 'new')['id'];
  });
}
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
    if (_selectedZoneId == null || _selectedTrackId == null || 
        _selectedZoneId == 'new' || _selectedTrackId == 'new') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select Zone and Track')));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .collection('zones')
          .doc(_selectedZoneId)
          .collection('tracks')
          .doc(_selectedTrackId)
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
      body: _isInitializing 
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    DropdownButtonFormField<String>(
  decoration: const InputDecoration(labelText: 'Select Zone'),
  value: _zones.any((z) => z['id'] == _selectedZoneId) ? _selectedZoneId : null,
  items: _zones.map((zone) {
    return DropdownMenuItem<String>(
      value: zone['id'] as String,
      child: Text(zone['title'] as String),
    );
  }).toList(),
  onChanged: (val) async {
    if (val == 'new') {
      await _navigateToCreateZoneScreen();
    } else {
      setState(() {
        _selectedZoneId = val;
        _selectedTrackId = null;
      });
      await _fetchTracksForZone(val);
    }
  },
  validator: (val) => val == null || val == 'new' ? 'Please select a Zone' : null,
),

                    const SizedBox(height: 12),
                    if (_selectedZoneId != null && _selectedZoneId != 'new')
                     DropdownButtonFormField<String>(
  decoration: const InputDecoration(labelText: 'Select Track'),
  value: _tracks.any((t) => t['id'] == _selectedTrackId) ? _selectedTrackId : null,
  items: _tracks.map((track) {
    return DropdownMenuItem<String>(
      value: track['id'] as String,
      child: Text(track['title'] as String),
    );
  }).toList(),
  onChanged: (val) async {
    if (val == 'new') {
      await _navigateToCreateTrackScreen(_selectedZoneId!);
    } else {
      setState(() {
        _selectedTrackId = val;
      });
    }
  },
  validator: (val) => val == null || val == 'new' ? 'Please select a Track' : null,
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