import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_management_app1/features/common/GenericEditForm.dart';
import 'package:event_management_app1/features/common/GenericFormScreen.dart';
import 'package:flutter/material.dart';

class DetailActions extends StatelessWidget {
  final String title;
  final CollectionReference<Map<String, dynamic>> collectionRef;
  final String docId;
  final Map<String, dynamic> initialData;
  final VoidCallback? onDeleteSuccess;

  const DetailActions({
    super.key,
    required this.title,
    required this.collectionRef,
    required this.docId,
    required this.initialData,
    this.onDeleteSuccess,
  });

  Future<void> _confirmAndDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Confirmation'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirm == true) {
      await collectionRef.doc(docId).delete();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item deleted successfully')),
        );
        onDeleteSuccess?.call();
        Navigator.pop(context); // Go back after deletion
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.edit),
          label: const Text('Edit'),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(
              builder: (_) => GenericEditForm(
                title: 'Edit $title',
                collectionRef: collectionRef,
                docId: docId,
                initialData: initialData,
              ),
            ));
          },
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          icon: const Icon(Icons.delete),
          label: const Text('Delete'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () => _confirmAndDelete(context),
        ),
      ],
    );
  }
}
