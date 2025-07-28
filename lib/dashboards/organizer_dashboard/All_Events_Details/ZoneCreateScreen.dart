import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_management_app1/dashboards/organizer_dashboard/services/cache_manager.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class ZoneCreateScreen extends StatefulWidget {
  final String eventId;

  const ZoneCreateScreen({super.key, required this.eventId});

  @override
  State<ZoneCreateScreen> createState() => _ZoneCreateScreenState();
}

class _ZoneCreateScreenState extends State<ZoneCreateScreen> {
  final TextEditingController _zoneNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final CacheManager _cacheManager = CacheManager();
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
      // Create a document with an auto-generated ID
      final docRef = FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .collection('zones')
          .doc();

      final zoneData = {
        'title': zoneName,
        'description': description,
        'createdAt': Timestamp.now(),
      };

      await docRef.set(zoneData);

      final newZone = {
        ...zoneData,
        'id': docRef.id,
      };

      final cacheKey = 'zones_${widget.eventId}';
      final existing = _cacheManager.get(cacheKey) ?? [];
      existing.insert(0, newZone);
      _cacheManager.save(cacheKey, existing);

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
  void dispose() {
    _zoneNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text("Create Zone"),
            ),
          ],
        ),
      ),
    );
  }
}
