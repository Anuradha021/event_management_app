import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/event_widgets/DropdownWidgets.dart';
import 'package:event_management_app1/dashboards/organizer_dashboard/services/session_firestore_service.dart';
import 'package:flutter/material.dart';


class SessionForm extends StatefulWidget {
  final String eventId;
  final String? zoneId;
  final String? trackId;

  const SessionForm({
    super.key,
    required this.eventId,
    this.zoneId,
    this.trackId,
  });

  @override
  State<SessionForm> createState() => _SessionFormState();
}

class _SessionFormState extends State<SessionForm> {
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

    fetchZones(widget.eventId).then((zones) async {
      setState(() => _zones = zones); 
      if (_selectedZoneId != null && _selectedZoneId != 'new') {
        _tracks = await fetchTracksForZone(widget.eventId, _selectedZoneId!);
      }
      _isInitializing = false;
      setState(() {});
    });
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

    if (_selectedZoneId == null || _selectedTrackId == null || _selectedZoneId == 'new' || _selectedTrackId == 'new') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select Zone and Track')));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await saveSession(
        eventId: widget.eventId,
        zoneId: _selectedZoneId!,
        trackId: _selectedTrackId!,
        title: _sessionTitleController.text.trim(),
        speaker: _speakerController.text.trim(),
        description: _descriptionController.text.trim(),
        startTime: _startTime!,
        endTime: _endTime!,
        context: context,
      );

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
    if (_isInitializing) return const Center(child: CircularProgressIndicator());

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            SessionDropdowns(
              eventId: widget.eventId,
              selectedZoneId: _selectedZoneId,
              selectedTrackId: _selectedTrackId,
              zones: _zones,
              tracks: _tracks,
              onZoneChanged: (val, tracks) {
                setState(() {
                  _selectedZoneId = val;
                  _tracks = tracks;
                  _selectedTrackId = null;
                });
              },
              onTrackChanged: (val) => setState(() => _selectedTrackId = val),
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
              title: Text(_startTime == null ? 'Pick Start Time' : 'Start Time: ${_startTime!.format(context)}'),
              trailing: const Icon(Icons.access_time),
              onTap: () => _pickTime(true),
            ),
            ListTile(
              title: Text(_endTime == null ? 'Pick End Time' : 'End Time: ${_endTime!.format(context)}'),
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
    );
  }
}
