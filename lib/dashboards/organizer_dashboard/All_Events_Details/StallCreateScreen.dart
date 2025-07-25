import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StallCreateScreen extends StatefulWidget {
  final String eventId;

  const StallCreateScreen({super.key, required this.eventId});

  @override
  State<StallCreateScreen> createState() => _StallCreateScreenState();
}

class _StallCreateScreenState extends State<StallCreateScreen> {
  final TextEditingController _stallNameController = TextEditingController();

  void _createStall() async {
    final stallName = _stallNameController.text.trim();
    if (stallName.isEmpty) return;

    try {
      await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .collection('stalls')
          .add({
        'stallName': stallName,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Stall created successfully!")),
      );

      Navigator.pop(context);
    } catch (e) {
      print("Error creating stall: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Stall")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _stallNameController,
              decoration: const InputDecoration(labelText: "Stall Name"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _createStall, child: const Text("Create")),
          ],
        ),
      ),
    );
  }
}
