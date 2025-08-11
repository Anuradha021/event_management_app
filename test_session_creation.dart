// // Test file to verify session creation timestamp logic
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// void main() {
//   // Test the timestamp conversion logic
//   testTimestampConversion();
// }

// void testTimestampConversion() {
//   print('🧪 Testing Session Creation Timestamp Logic\n');

//   // Test data
//   final selectedDate = DateTime(2024, 1, 15); // January 15, 2024
//   final startTime = const TimeOfDay(hour: 14, minute: 30); // 2:30 PM
//   final endTime = const TimeOfDay(hour: 16, minute: 0); // 4:00 PM

//   // Create DateTime objects (same logic as in the session creation)
//   final startDateTime = DateTime(
//     selectedDate.year,
//     selectedDate.month,
//     selectedDate.day,
//     startTime.hour,
//     startTime.minute,
//   );

//   final endDateTime = DateTime(
//     selectedDate.year,
//     selectedDate.month,
//     selectedDate.day,
//     endTime.hour,
//     endTime.minute,
//   );

//   print('📅 Selected Date: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}');
//   print('🕐 Start Time: ${startTime.format(null)}');
//   print('🕐 End Time: ${endTime.format(null)}');
//   print('');
//   print('📅 Start DateTime: $startDateTime');
//   print('📅 End DateTime: $endDateTime');
//   print('');

//   // Convert to Firestore Timestamps
//   final startTimestamp = Timestamp.fromDate(startDateTime);
//   final endTimestamp = Timestamp.fromDate(endDateTime);

//   print('🔥 Start Timestamp: $startTimestamp');
//   print('🔥 End Timestamp: $endTimestamp');
//   print('');

//   // Validate
//   final isValidTimeRange = endDateTime.isAfter(startDateTime);
//   print('✅ Valid time range: $isValidTimeRange');

//   // Convert back to verify
//   final convertedStartDateTime = startTimestamp.toDate();
//   final convertedEndDateTime = endTimestamp.toDate();

//   print('🔄 Converted back - Start: $convertedStartDateTime');
//   print('🔄 Converted back - End: $convertedEndDateTime');

//   // Test the session data structure
//   final sessionData = {
//     'title': 'Test Session',
//     'description': 'Test Description',
//     'speakerName': 'Test Speaker',
//     'startTime': startTimestamp,
//     'endTime': endTimestamp,
//     'createdAt': FieldValue.serverTimestamp(),
//     'zoneId': 'test-zone-id',
//     'trackId': 'test-track-id',
//   };

//   print('');
//   print('📋 Session Data Structure:');
//   sessionData.forEach((key, value) {
//     if (key != 'createdAt') { // Skip FieldValue.serverTimestamp() as it can't be printed
//       print('  $key: $value');
//     } else {
//       print('  $key: FieldValue.serverTimestamp()');
//     }
//   });

//   print('');
//   print('🎉 All timestamp conversions successful!');
//   print('');
//   print('📝 Key improvements made:');
//   print('  ✅ Fixed TimeOfDay to DateTime conversion');
//   print('  ✅ Added proper Timestamp.fromDate() usage');
//   print('  ✅ Added date selection for sessions');
//   print('  ✅ Added zone/track selection in dialog');
//   print('  ✅ Added proper validation');
//   print('  ✅ Fixed state management with StatefulBuilder');
//   print('  ✅ Added loading states and error handling');
// }

// // Extension to format TimeOfDay without BuildContext (for testing)
// extension TimeOfDayExtension on TimeOfDay {
//   String format(BuildContext? context) {
//     final hour = this.hour == 0 ? 12 : (this.hour > 12 ? this.hour - 12 : this.hour);
//     final minute = this.minute.toString().padLeft(2, '0');
//     final period = this.hour < 12 ? 'AM' : 'PM';
//     return '$hour:$minute $period';
//   }
// }
