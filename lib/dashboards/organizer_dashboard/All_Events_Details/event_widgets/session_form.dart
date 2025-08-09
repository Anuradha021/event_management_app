// import 'package:event_management_app1/dashboards/organizer_dashboard/All_Events_Details/event_widgets/DropdownWidgets.dart';
// import 'package:event_management_app1/dashboards/organizer_dashboard/services/session_firestore_service.dart';
// import 'package:flutter/material.dart';

// class SessionForm extends StatefulWidget {
//   final String eventId;
//   final String? zoneId;
//   final String? trackId;

//   const SessionForm({
//     super.key,
//     required this.eventId,
//     this.zoneId,
//     this.trackId,
//   });

//   @override
//   State<SessionForm> createState() => _SessionFormState();
// }

// class _SessionFormState extends State<SessionForm> {
//   final _formKey = GlobalKey<FormState>();
//   final _sessionTitleController = TextEditingController();
//   final _speakerController = TextEditingController();
//   final _descriptionController = TextEditingController();

//   List<Map<String, dynamic>> _zones = [];
//   List<Map<String, dynamic>> _tracks = [];

//   String? _selectedZoneId;
//   String? _selectedTrackId;
//   TimeOfDay? _startTime, _endTime;
//   bool _isSubmitting = false;
//   bool _isInitializing = true;
//   bool _useDefaultZoneTrack = false;

//   @override
//   void initState() {
//     super.initState();
//     _selectedZoneId = widget.zoneId;
//     _selectedTrackId = widget.trackId;
//     _initializeData();
//   }

//   Future<void> _initializeData() async {
//     final zones = await fetchZones(widget.eventId);
//     setState(() => _zones = zones);
    
//     if (_selectedZoneId != null && _selectedZoneId != 'new') {
//       final tracks = await fetchTracksForZone(widget.eventId, _selectedZoneId!);
//       setState(() => _tracks = tracks);
//     }
    
//     setState(() => _isInitializing = false);
//   }

//   Future<void> _pickTime(bool isStart) async {
//     final picked = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: ColorScheme.light(
//               primary: Colors.deepPurple,
//               onPrimary: Colors.white,
//               onSurface: Colors.black,
//             ),
//             timePickerTheme: TimePickerThemeData(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
    
//     if (picked != null) {
//       setState(() {
//         if (isStart) _startTime = picked;
//         else _endTime = picked;
//       });
//     }
//   }

//   Future<void> _submitSession() async {
//     if (!_formKey.currentState!.validate()) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please fill all required fields')),
//       );
//       return;
//     }

//     if (_startTime == null || _endTime == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select both start and end times')),
//       );
//       return;
//     }

//     // Check if user wants to use default zone/track or has selected specific ones
//     if (!_useDefaultZoneTrack && (_selectedZoneId == null || _selectedTrackId == null)) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select both Zone and Track or enable default zone/track')),
//       );
//       return;
//     }

//     setState(() => _isSubmitting = true);

//     try {
//       await saveSession(
//         eventId: widget.eventId,
//         zoneId: _useDefaultZoneTrack ? null : _selectedZoneId,
//         trackId: _useDefaultZoneTrack ? null : _selectedTrackId,
//         title: _sessionTitleController.text.trim(),
//         speaker: _speakerController.text.trim(),
//         description: _descriptionController.text.trim(),
//         startTime: _startTime!,
//         endTime: _endTime!,
//         context: context,
//       );

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Session created successfully!')),
//       );
//       Navigator.pop(context, true);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error creating session: ${e.toString()}")),
//       );
//     } finally {
//       setState(() => _isSubmitting = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isInitializing) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     return Form(
//       key: _formKey,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           // Default Zone/Track Option
//           Card(
//             margin: const EdgeInsets.only(bottom: 16),
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Checkbox(
//                         value: _useDefaultZoneTrack,
//                         onChanged: (value) {
//                           setState(() {
//                             _useDefaultZoneTrack = value ?? false;
//                             if (_useDefaultZoneTrack) {
//                               _selectedZoneId = null;
//                               _selectedTrackId = null;
//                             }
//                           });
//                         },
//                       ),
//                       const Expanded(
//                         child: Text(
//                           'Use Default Zone and Track',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   if (_useDefaultZoneTrack)
//                     Padding(
//                       padding: const EdgeInsets.only(left: 48, top: 8),
//                       child: Text(
//                         'Session will be assigned to the default zone and track',
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Colors.grey[600],
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ),
          
//           // Zone and Track Selection (only show if not using defaults)
//           if (!_useDefaultZoneTrack) ...[
//             SessionDropdowns(
//               eventId: widget.eventId,
//               selectedZoneId: _selectedZoneId,
//               selectedTrackId: _selectedTrackId,
//               zones: _zones,
//               tracks: _tracks,
//               onZoneChanged: (val, tracks) {
//                 setState(() {
//                   _selectedZoneId = val;
//                   _tracks = tracks;
//                   _selectedTrackId = null;
//                 });
//               },
//               onTrackChanged: (val) => setState(() => _selectedTrackId = val),
//             ),
//             const SizedBox(height: 20),
//           ],
          
//           _buildTextFormField(
//             controller: _sessionTitleController,
//             label: 'Session Title',
//             isRequired: true,
//           ),
//           const SizedBox(height: 16),
//           _buildTextFormField(
//             controller: _speakerController,
//             label: 'Speaker Name',
//             isRequired: true,
//           ),
//           const SizedBox(height: 16),
//           _buildTimePickerField(
//             label: 'Start Time',
//             time: _startTime,
//             onTap: () => _pickTime(true),
//           ),
//           const SizedBox(height: 16),
//           _buildTimePickerField(
//             label: 'End Time',
//             time: _endTime,
//             onTap: () => _pickTime(false),
//           ),
//           const SizedBox(height: 16),
//           _buildTextFormField(
//             controller: _descriptionController,
//             label: 'Description',
//             isRequired: false,
//             maxLines: 4,
//           ),
//           const SizedBox(height: 24),
//           ElevatedButton(
//             onPressed: _isSubmitting ? null : _submitSession,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.deepPurple,
//               padding: const EdgeInsets.symmetric(vertical: 16),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//             child: _isSubmitting
//                 ? const CircularProgressIndicator(color: Colors.white)
//                 : const Text(
//                     'Create Session',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTextFormField({
//     required TextEditingController controller,
//     required String label,
//     bool isRequired = false,
//     int maxLines = 1,
//   }) {
//     return TextFormField(
//       controller: controller,
//       decoration: InputDecoration(
//         labelText: label,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//         ),
//         filled: true,
//         fillColor: Colors.grey[50],
//       ),
//       maxLines: maxLines,
//       validator: isRequired
//           ? (val) => val == null || val.isEmpty ? 'This field is required' : null
//           : null,
//     );
//   }

//   Widget _buildTimePickerField({
//     required String label,
//     required TimeOfDay? time,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.grey.shade300),
//           borderRadius: BorderRadius.circular(10),
//           color: Colors.grey[50],
//         ),
//         child: Row(
//           children: [
//             Icon(Icons.access_time, color: Colors.grey[600]),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text(
//                 time != null ? time.format(context) : 'Select $label',
//                 style: TextStyle(
//                   color: time != null ? Colors.black : Colors.grey[600],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }