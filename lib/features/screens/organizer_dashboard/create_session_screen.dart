import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_management_app1/features/screens/organizer_dashboard/widgets/CustomTextField.dart';
import 'package:event_management_app1/features/screens/organizer_dashboard/widgets/CustomTimePicker.dart';
import 'package:flutter/material.dart';

class SessionCreateScreen extends StatefulWidget {
  final String eventId;
  final String subEventId;

  const SessionCreateScreen({super.key, required this.eventId, required this.subEventId});

  @override
  State<SessionCreateScreen> createState() => _SessionCreateScreenState();
}

class _SessionCreateScreenState extends State<SessionCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _speakerController = TextEditingController();
  final _descController = TextEditingController();

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isSubmitting = false;

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) {
      setState(() => isStart ? _startTime = picked : _endTime = picked);
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _submitSession() async {
    if (!_formKey.currentState!.validate() || _startTime == null || _endTime == null) {
      _showMessage('Please fill all fields');
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

      _showMessage('Session Created Successfully');
      Navigator.pop(context, true);
    } catch (e) {
      _showMessage('Error: $e');
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
              CustomTextField(controller: _titleController, label: 'Session Title'),
              CustomTextField(controller: _speakerController, label: 'Speaker Name'),
              CustomTimePicker(label: 'Start Time', time: _startTime, onTap: () => _pickTime(true)),
              CustomTimePicker(label: 'End Time', time: _endTime, onTap: () => _pickTime(false)),
              CustomTextField(controller: _descController, label: 'Description', maxLines: 3),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitSession,
                  child: _isSubmitting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Create Session'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
