// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class CreateTrackScreen extends StatefulWidget {
//   final String eventId;

//   const CreateTrackScreen({super.key, required this.eventId});

//   @override
//   State<CreateTrackScreen> createState() => _CreateTrackScreenState();
// }

// class _CreateTrackScreenState extends State<CreateTrackScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _titleController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();
//   bool _isSubmitting = false;
//   bool _isDefault = false;

//   Future<void> _submitTrack() async {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }

//     setState(() => _isSubmitting = true);

//     try {
//       await FirebaseFirestore.instance
//           .collection('events')
//           .doc(widget.eventId)
//           .collection('tracks')
//           .add({
//         'title': _titleController.text.trim(),
//         'description': _descriptionController.text.trim(),
//         'isDefault': _isDefault,
//         'createdAt': Timestamp.now(),
//         'eventId': widget.eventId,
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Track created successfully')),
//       );
//       Navigator.pop(context, true);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error creating track: $e')),
//       );
//     } finally {
//       setState(() => _isSubmitting = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Create Track')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: [
//               TextFormField(
//                 controller: _titleController,
//                 decoration: const InputDecoration(
//                   labelText: 'Track Title',
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a title';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _descriptionController,
//                 decoration: const InputDecoration(
//                   labelText: 'Description',
//                   border: OutlineInputBorder(),
//                 ),
//                 maxLines: 3,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a description';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               SwitchListTile(
//                 title: const Text('Set as default track'),
//                 subtitle: const Text('Sessions can be assigned to this track automatically'),
//                 value: _isDefault,
//                 onChanged: (value) {
//                   setState(() {
//                     _isDefault = value;
//                   });
//                 },
//               ),
//               const SizedBox(height: 24),
//               ElevatedButton(
//                 onPressed: _isSubmitting ? null : _submitTrack,
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                 ),
//                 child: _isSubmitting
//                     ? const CircularProgressIndicator()
//                     : const Text('Create Track'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _descriptionController.dispose();
//     super.dispose();
//   }
// }