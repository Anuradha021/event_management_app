import 'package:flutter/material.dart';

class UpdateSessionDialog extends StatelessWidget {
  final String currentTitle;
  final String currentDescription;
  final String currentSpeaker;
  final Future<void> Function(String title, String desc, String speaker) onUpdate;

  const UpdateSessionDialog({
    super.key,
    required this.currentTitle,
    required this.currentDescription,
    required this.currentSpeaker,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final titleController = TextEditingController(text: currentTitle);
    final descController = TextEditingController(text: currentDescription);
    final speakerController = TextEditingController(text: currentSpeaker);

    return AlertDialog(
      title: const Text('Update Session'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: 'Session Title',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: speakerController,
            decoration: const InputDecoration(
              labelText: 'Speaker Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: descController,
            decoration: const InputDecoration(
              labelText: 'Description ',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (titleController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Session title cannot be empty')),
              );
              return;
            }
            await onUpdate(
              titleController.text.trim(),
              descController.text.trim(),
              speakerController.text.trim(),
            );
          },
          child: const Text('Update'),
        ),
      ],
    );
  }
}
