import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/ZoneDetailsScreens.dart';
import 'package:flutter/material.dart';

class ZoneCreateScreen extends StatefulWidget {
  final String eventId;
  const ZoneCreateScreen({super.key, required this.eventId});

  @override
  State<ZoneCreateScreen> createState() => _ZoneCreateScreenState();
}

class _ZoneCreateScreenState extends State<ZoneCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitZone() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final docRef = await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .collection('zones')
          .add({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'createdAt': Timestamp.now(),
      });

      // After creation, navigate to the ZoneDetailScreen of the newly created zone
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ZoneDetailScreen(
            eventId: widget.eventId,
            zoneId: docRef.id,
            zoneData: {
              'title': _titleController.text.trim(),
              'description': _descriptionController.text.trim(),
              // Add other relevant data if ZoneDetailScreen expects it
            },
          ),
        ),
      );
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
      appBar: AppBar(title: const Text('Create Zone')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Zone Title'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
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
