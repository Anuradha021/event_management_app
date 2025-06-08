import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CreateEventScreen extends StatefulWidget {
  final Map<String, dynamic>? requestData;
  
  const CreateEventScreen({super.key, this.requestData});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _organizerEmailController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedCategory;

  final List<String> categories = [
    'Technology',
    'Art & Culture',
    'Education',
    'Health',
    'Business'
  ];

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.requestData != null) {
      _titleController.text = widget.requestData!['eventTitle'] ?? '';
      _descController.text = widget.requestData!['eventDescription'] ?? '';
      _organizerEmailController.text = widget.requestData!['organizerEmail'] ?? '';
      _locationController.text = widget.requestData!['location'] ?? '';
      _selectedDate = widget.requestData!['eventDate']?.toDate();
    }
  }

 Future<void> _submitForm() async {
  if (!_formKey.currentState!.validate() || _selectedDate == null || _selectedCategory == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please fill in all fields')),
    );
    return;
  }

  setState(() => _isSubmitting = true);

  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to create an event')),
      );
      setState(() => _isSubmitting = false);
      return;
    }

    await FirebaseFirestore.instance.collection('event_requests').add({
      'eventTitle': _titleController.text,
      'eventDescription': _descController.text,
      'date': _selectedDate,
      'location': _locationController.text,
      'organizerEmail': _organizerEmailController.text,
      'organizerUid': user.uid,
      'category': _selectedCategory,
      'status': 'pending',
      'createdAt': Timestamp.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Event created successfully')),
    );

    Navigator.pop(context, true);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to create event: $e')),
    );
  } finally {
    setState(() => _isSubmitting = false);
  }
}

  
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );

    if (pickedDate != null) {
      setState(() => _selectedDate = pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Event')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Event Title'),
                validator: (value) => value!.isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? 'Description is required' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _organizerEmailController,
                decoration: const InputDecoration(labelText: 'Organizer Email'),
                validator: (value) => value!.isEmpty ? 'Email is required' : null,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (value) => value!.isEmpty ? 'Location is required' : null,
              ),
              const SizedBox(height: 10),
              ListTile(
                title: Text(
                  _selectedDate == null
                      ? 'Pick Event Date'
                      : 'Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Category'),
                items: categories
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedCategory = value),
                validator: (value) => value == null ? 'Category is required' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                child: _isSubmitting
                    ? const CircularProgressIndicator()
                    : const Text('Create Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}