import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class SessionCreateScreen extends StatefulWidget {
  final String eventId;
  final String zoneId;
  final String trackId;

  const SessionCreateScreen({
    super.key,
    required this.eventId,
    required this.zoneId,
    required this.trackId,
  });

  @override
  State<SessionCreateScreen> createState() => _SessionCreateScreenState();
}

class _SessionCreateScreenState extends State<SessionCreateScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _speakerController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  bool _isLoading = false;

  void _createSession() async {
    final title = _titleController.text.trim();
    final speaker = _speakerController.text.trim();

    if (title.isEmpty || speaker.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final sessionId = const Uuid().v4();

      await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .collection('zones')
          .doc(widget.zoneId)
          .collection('tracks')
          .doc(widget.trackId)
          .collection('sessions')
          .doc(sessionId)
          .set({
        'sessionId': sessionId,
        'title': title,
        'speakerName': speaker,
        'startTime': _startTimeController.text.trim(),
        'endTime': _endTimeController.text.trim(),
        'description': _descController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Session Created")));
      _titleController.clear();
      _speakerController.clear();
      _startTimeController.clear();
      _endTimeController.clear();
      _descController.clear();
    } catch (e) {
      print("Error creating session: $e");
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Session')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Title')),
            TextField(controller: _speakerController, decoration: const InputDecoration(labelText: 'Speaker Name')),
            TextField(controller: _startTimeController, decoration: const InputDecoration(labelText: 'Start Time')),
            TextField(controller: _endTimeController, decoration: const InputDecoration(labelText: 'End Time')),
            TextField(controller: _descController, decoration: const InputDecoration(labelText: 'Description')),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _createSession,
                    child: const Text('Create Session'),
                  ),
          ],
        ),
      ),
    );
  }
}
