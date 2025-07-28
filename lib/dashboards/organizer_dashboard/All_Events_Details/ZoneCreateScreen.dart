import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ZoneCreateScreen extends StatefulWidget {
  final String eventId;

  const ZoneCreateScreen({super.key, required this.eventId});

  @override
  State<ZoneCreateScreen> createState() => _ZoneCreateScreenState();
}

class _ZoneCreateScreenState extends State<ZoneCreateScreen> {
  final TextEditingController _zoneNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;

  Future<void> _createZone() async {
    final zoneName = _zoneNameController.text.trim();
    final description = _descriptionController.text.trim();

    if (zoneName.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter zone name and description")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .collection('zones')
          .add({
        'title': zoneName,
        'description': description,
        'createdAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Zone created successfully")),
      );

      _zoneNameController.clear();
      _descriptionController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Zone")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _zoneNameController,
              decoration: const InputDecoration(labelText: "Zone Name"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: "Description"),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _createZone,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Create Zone"),
            ),
          ],
        ),
      ),
    );
  }
}
