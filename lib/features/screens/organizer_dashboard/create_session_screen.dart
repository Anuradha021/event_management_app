import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SessionCreateScreen extends StatefulWidget {
  final String eventId;
  final String subEventId;

  const SessionCreateScreen({
    super.key,
    required this.eventId,
    required this.subEventId,
  });

  @override
  State<SessionCreateScreen> createState() => _SessionCreateScreenState();
}

class _SessionCreateScreenState extends State<SessionCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _speakerController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isSubmitting = false;

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _submitSession() async {
    if (!_formKey.currentState!.validate() ||
        _startTime == null ||
        _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .collection('subEvents')
          .doc(widget.subEventId)
          .collection('sessions')
          .add({
        'title': _titleController.text.trim(),
        'speakerName': _speakerController.text.trim(),
        'description': _descController.text.trim(),
        'startTime': _startTime!.format(context),
        'endTime': _endTime!.format(context),
        'createdAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session Created Successfully')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
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
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Session Title'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _speakerController,
                decoration: const InputDecoration(labelText: 'Speaker Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              ListTile(
                title: Text(_startTime == null
                    ? 'Pick Start Time'
                    : 'Start Time: ${_startTime!.format(context)}'),
                trailing: const Icon(Icons.access_time),
                onTap: () => _pickTime(true),
              ),
              ListTile(
                title: Text(_endTime == null
                    ? 'Pick End Time'
                    : 'End Time: ${_endTime!.format(context)}'),
                trailing: const Icon(Icons.access_time),
                onTap: () => _pickTime(false),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
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
