import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ContactForm extends StatefulWidget {
  final bool skipOrganizerCheck;
  final bool isFromDashboard;
  const ContactForm({super.key, this.skipOrganizerCheck = false, required this.isFromDashboard,  });

  @override
  State<ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _eventTitleController = TextEditingController();
  final TextEditingController _eventDescController = TextEditingController();
  final TextEditingController _organizerNameController = TextEditingController();
  final TextEditingController _organizerEmailController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  DateTime? _selectedDate;

  Future<void> _submitRequest() async {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You must be logged in to submit a request')),
          );
          return;
        }

        await FirebaseFirestore.instance.collection('event_requests').add({
          'eventTitle': _eventTitleController.text,
          'eventDescription': _eventDescController.text,
          'organizerName': _organizerNameController.text,
          'organizerEmail': _organizerEmailController.text,
          'organizerUid': user.uid,
          'location': _locationController.text,
          'eventDate': _selectedDate,
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event request submitted successfully')),
        );

        _formKey.currentState!.reset();
        _eventTitleController.clear();
        _eventDescController.clear();
        _organizerNameController.clear();
        _organizerEmailController.clear();
        _locationController.clear();
        setState(() => _selectedDate = null);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit request: \$e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Request to Organize Event")),
      body: 
           Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _eventTitleController,
                        decoration: const InputDecoration(labelText: "Event Title"),
                        validator: (value) => value!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _eventDescController,
                        decoration: const InputDecoration(labelText: "Event Description"),
                        maxLines: 3,
                        validator: (value) => value!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _organizerNameController,
                        decoration: const InputDecoration(labelText: "Organizer Name"),
                        validator: (value) => value!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _organizerEmailController,
                        decoration: const InputDecoration(labelText: "Organizer Email"),
                        validator: (value) => value!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(labelText: "Event Location"),
                        validator: (value) => value!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _selectedDate == null
                                  ? 'No date selected'
                                  : "Event Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}",
                            ),
                          ),
                          ElevatedButton(
                            onPressed: _pickDate,
                            child: const Text('Select Date'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _submitRequest,
                        child: const Text("Submit Request"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
