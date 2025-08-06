import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;

  Future<void> _createStall() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter stall name')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .collection('zones')
          .doc(widget.zoneId)
          .collection('tracks')
          .doc(widget.trackId)
          .collection('stalls')
          .doc()
          .set({
            'name': _nameController.text.trim(),
            'description': _descriptionController.text.trim(),
            'createdAt': FieldValue.serverTimestamp(),
            'eventId': widget.eventId,
            'zoneId': widget.zoneId,
            'trackId': widget.trackId,
          });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stall created successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating stall: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttonStyle = ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      minimumSize: const Size(double.infinity, 50),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Stall',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Stall Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.add, size: 20),
              label: const Text('CREATE STALL'),
              style: buttonStyle.copyWith(
                backgroundColor: MaterialStateProperty.all(Colors.deepPurple),
                foregroundColor: MaterialStateProperty.all(Colors.white),
              ),
              onPressed: _isLoading ? null : _createStall,
            ),
            if (_isLoading) const SizedBox(height: 10),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(
                  color: Colors.deepPurple,
                ),
              ),
          ],
        ),
      ),
    );
  }
}