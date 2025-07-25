import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CreateSessionScreen extends StatefulWidget {
  final String eventId;
  final String zoneId;
  final String trackId;

  const CreateSessionScreen({
    super.key,
    required this.eventId,
    required this.zoneId,
    required this.trackId,
  });

  @override
  State<CreateSessionScreen> createState() => _CreateSessionScreenState();
}

class _CreateSessionScreenState extends State<CreateSessionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _sessionTitleController = TextEditingController();
  final TextEditingController _speakerController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isSubmitting = false;

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
    if (!_formKey.currentState!.validate() ||
        _startTime == null ||
        _endTime == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final sessionsRef = FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .collection('zones')
          .doc(widget.zoneId)
          .collection('tracks')
          .doc(widget.trackId)
          .collection('sessions');

      await sessionsRef.add({
        'title': _sessionTitleController.text.trim(),
        'speakerName': _speakerController.text.trim(),
        'description': _descriptionController.text.trim(),
        'startTime': _startTime!.format(context),
        'endTime': _endTime!.format(context),
        'createdAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Session Created')));

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Session/Stall')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _sessionTitleController,
                decoration: const InputDecoration(labelText: 'Session Title'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _speakerController,
                decoration: const InputDecoration(labelText: 'Speaker Name'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              ListTile(
                title: Text(_startTime == null
                    ? 'Pick Start Time'
                    : 'Start: ${_startTime!.format(context)}'),
                trailing: const Icon(Icons.access_time),
                onTap: () => _pickTime(true),
              ),
              ListTile(
                title: Text(_endTime == null
                    ? 'Pick End Time'
                    : 'End: ${_endTime!.format(context)}'),
                trailing: const Icon(Icons.access_time),
                onTap: () => _pickTime(false),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? 'Required' : null,
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
