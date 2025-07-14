import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SubEventCreateScreen extends StatefulWidget {
  final String eventId;

  const SubEventCreateScreen({super.key, required this.eventId});

  @override
  State<SubEventCreateScreen> createState() => _SubEventCreateScreenState();
}

class _SubEventCreateScreenState extends State<SubEventCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _venueController = TextEditingController();
  final TextEditingController _maxParticipantsController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String? _selectedType;

  final List<String> subEventTypes = [
    'Seminar',
    'Workshop',
    'Exhibition',
    'Networking',
    'Other',
  ];

  bool _isSubmitting = false;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) {
      setState(() {
        if (isStart) _startTime = picked;
        else _endTime = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null || _startTime == null || _endTime == null || _selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await FirebaseFirestore.instance.collection('events').doc(widget.eventId).collection('subEvents').add({
        'subEventTitle': _titleController.text.trim(),
        'subEventDescription': _descController.text.trim(),
        'subEventDate': Timestamp.fromDate(_selectedDate!),
        'startTime': _startTime!.format(context),
        'endTime': _endTime!.format(context),
        'venue': _venueController.text.trim(),
        'maxParticipants': int.tryParse(_maxParticipantsController.text.trim()) ?? 0,
        'subEventType': _selectedType,
        'createdAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sub-Event Created')));
      Navigator.pop(context, true);
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Sub-Event')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(controller: _titleController, decoration: const InputDecoration(labelText: 'Title'), validator: (v) => v!.isEmpty ? 'Required' : null),
              TextFormField(controller: _descController, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3, validator: (v) => v!.isEmpty ? 'Required' : null),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Type'),
                items: subEventTypes.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => _selectedType = v),
                validator: (v) => v == null ? 'Required' : null,
              ),
              ListTile(title: Text(_selectedDate == null ? 'Pick Date' : 'Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}'), trailing: const Icon(Icons.calendar_today), onTap: _pickDate),
              Row(
                children: [
                  Expanded(child: ListTile(title: Text(_startTime == null ? 'Start Time' : _startTime!.format(context)), onTap: () => _pickTime(true))),
                  Expanded(child: ListTile(title: Text(_endTime == null ? 'End Time' : _endTime!.format(context)), onTap: () => _pickTime(false))),
                ],
              ),
              TextFormField(controller: _venueController, decoration: const InputDecoration(labelText: 'Venue'), validator: (v) => v!.isEmpty ? 'Required' : null),
              TextFormField(controller: _maxParticipantsController, decoration: const InputDecoration(labelText: 'Max Participants'), keyboardType: TextInputType.number),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _isSubmitting ? null : _submit, child: _isSubmitting ? const CircularProgressIndicator() : const Text('Create Sub-Event')),
            ],
          ),
        ),
      ),
    );
  }
}
