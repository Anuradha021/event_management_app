import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CreateTrackScreen extends StatefulWidget {
  final String eventId;
  final String subEventId;

  const CreateTrackScreen({
    super.key,
    required this.eventId,
    required this.subEventId,
  });

  @override
  State<CreateTrackScreen> createState() => _CreateTrackScreenState();
}

class _CreateTrackScreenState extends State<CreateTrackScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitTrack() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .collection('subEvents')
          .doc(widget.subEventId)
          .collection('tracks')
          .add({
        'trackTitle': _titleController.text.trim(),
        'trackDescription': _descController.text.trim(),
        'createdAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Track Created Successfully')));
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Track')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Track Title'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Track Description'),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitTrack,
                child: _isSubmitting ? const CircularProgressIndicator() : const Text('Create Track'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
