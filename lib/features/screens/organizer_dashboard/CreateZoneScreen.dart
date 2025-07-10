import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CreateZoneScreen extends StatefulWidget {
  final String eventId;
  final String subEventId;
  final String trackId;

  const CreateZoneScreen({
    super.key,
    required this.eventId,
    required this.subEventId,
    required this.trackId,
  });

  @override
  State<CreateZoneScreen> createState() => _CreateZoneScreenState();
}

class _CreateZoneScreenState extends State<CreateZoneScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _zoneTitleController = TextEditingController();
  final TextEditingController _zoneDescController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitZone() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .collection('subEvents')
          .doc(widget.subEventId)
          .collection('tracks')
          .doc(widget.trackId)
          .collection('zones')
          .add({
        'zoneTitle': _zoneTitleController.text.trim(),
        'zoneDescription': _zoneDescController.text.trim(),
        'createdAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Zone Created Successfully')));
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
      appBar: AppBar(title: const Text('Create Zone')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _zoneTitleController,
                decoration: const InputDecoration(labelText: 'Zone Title'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _zoneDescController,
                decoration: const InputDecoration(labelText: 'Zone Description'),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitZone,
                child: _isSubmitting
                    ? const CircularProgressIndicator()
                    : const Text('Create Zone'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
