import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class StallCreateScreen extends StatefulWidget {
  final String eventId;
  final String zoneId;
  final String trackId;

  const StallCreateScreen({
    super.key,
    required this.eventId,
    required this.zoneId,
    required this.trackId,
  });

  @override
  State<StallCreateScreen> createState() => _StallCreateScreenState();
}

class _StallCreateScreenState extends State<StallCreateScreen> {
  final TextEditingController _stallNameController = TextEditingController();
  final TextEditingController _stallDescriptionController = TextEditingController();
  bool _isLoading = false;

  void _createStall() async {
    final String stallName = _stallNameController.text.trim();
    final String stallDescription = _stallDescriptionController.text.trim();
    if (stallName.isEmpty || stallDescription.isEmpty) return;

    setState(() => _isLoading = true);

    final String stallId = const Uuid().v4();

    final stallRef = FirebaseFirestore.instance
        .collection('events')
        .doc(widget.eventId)
        .collection('zones')
        .doc(widget.zoneId)
        .collection('tracks')
        .doc(widget.trackId)
        .collection('stalls')
        .doc(stallId);

    await stallRef.set({
      'stallId': stallId,
      'name': stallName,
      'description': stallDescription,
      'createdAt': FieldValue.serverTimestamp(),
    });

    setState(() => _isLoading = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Stall')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _stallNameController,
              decoration: const InputDecoration(labelText: 'Stall Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _stallDescriptionController,
              decoration: const InputDecoration(labelText: 'Stall Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _createStall,
                    child: const Text('Create Stall'),
                  ),
          ],
        ),
      ),
    );
  }
}
