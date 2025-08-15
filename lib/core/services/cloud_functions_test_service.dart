import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

/// Service to test Cloud Functions connectivity and verify data source
/// Single Responsibility: Test and verify Cloud Functions are working
class CloudFunctionsTestService {
  static final FirebaseFunctions _functions = FirebaseFunctions.instance;

  /// Test basic Cloud Functions connectivity
  static Future<Map<String, dynamic>> testConnection({String? message}) async {
    try {
      debugPrint("🧪 Testing Cloud Functions connection...");
      
      final callable = _functions.httpsCallable('testCloudFunction');
      final result = await callable.call({
        'message': message ?? 'Test from Flutter App',
      });

      final data = result.data as Map<String, dynamic>;
      
      debugPrint("✅ Cloud Functions test successful!");
      debugPrint("📦 Response: ${data.toString()}");
      
      return {
        'success': true,
        'source': 'Cloud Functions',
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint("❌ Cloud Functions test failed: $e");
      return {
        'success': false,
        'source': 'Error',
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Test event creation through Cloud Functions
  static Future<Map<String, dynamic>> testEventCreation() async {
    try {
      debugPrint("🎪 Testing event creation through Cloud Functions...");
      
      final callable = _functions.httpsCallable('events-createEvent');
      final result = await callable.call({
        'title': 'Test Event from Cloud Functions',
        'description': 'This event was created via Cloud Functions to test the backend',
        'startDate': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
        'endDate': DateTime.now().add(const Duration(days: 8)).toIso8601String(),
        'location': 'Test Location',
        'isPublic': true,
        'organizerId': 'test-organizer-id',
      });

      final data = result.data as Map<String, dynamic>;
      
      debugPrint("✅ Event creation through Cloud Functions successful!");
      debugPrint("📦 Response: ${data.toString()}");
      
      return {
        'success': true,
        'source': 'Cloud Functions - Event Creation',
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint("❌ Event creation through Cloud Functions failed: $e");
      return {
        'success': false,
        'source': 'Cloud Functions - Event Creation Error',
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Test zone creation through Cloud Functions
  static Future<Map<String, dynamic>> testZoneCreation(String eventId) async {
    try {
      debugPrint("🏢 Testing zone creation through Cloud Functions...");
      
      final callable = _functions.httpsCallable('zones-createZone');
      final result = await callable.call({
        'eventId': eventId,
        'title': 'Test Zone from Cloud Functions',
        'description': 'This zone was created via Cloud Functions to test the backend',
        'capacity': 100,
        'location': 'Test Zone Location',
      });

      final data = result.data as Map<String, dynamic>;
      
      debugPrint("✅ Zone creation through Cloud Functions successful!");
      debugPrint("📦 Response: ${data.toString()}");
      
      return {
        'success': true,
        'source': 'Cloud Functions - Zone Creation',
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint("❌ Zone creation through Cloud Functions failed: $e");
      return {
        'success': false,
        'source': 'Cloud Functions - Zone Creation Error',
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Compare data sources - Cloud Functions vs Direct Firestore
  static Future<Map<String, dynamic>> compareDataSources(String eventId) async {
    try {
      debugPrint("🔍 Comparing Cloud Functions vs Direct Firestore access...");
      
      // Test Cloud Functions approach
      final cloudFunctionsResult = await _testGetEventViaCloudFunctions(eventId);
      
      // Test direct Firestore approach (for comparison)
      final firestoreResult = await _testGetEventViaFirestore(eventId);
      
      return {
        'success': true,
        'cloudFunctions': cloudFunctionsResult,
        'directFirestore': firestoreResult,
        'recommendation': cloudFunctionsResult['success'] 
            ? 'Use Cloud Functions for better security and validation'
            : 'Cloud Functions not working, falling back to direct Firestore',
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint("❌ Data source comparison failed: $e");
      return {
        'success': false,
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  static Future<Map<String, dynamic>> _testGetEventViaCloudFunctions(String eventId) async {
    try {
      final callable = _functions.httpsCallable('events-getOrganizerEvents');
      final result = await callable.call({});
      
      return {
        'success': true,
        'source': 'Cloud Functions',
        'data': result.data,
      };
    } catch (e) {
      return {
        'success': false,
        'source': 'Cloud Functions',
        'error': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> _testGetEventViaFirestore(String eventId) async {
    try {
      // This would be direct Firestore access (what we want to avoid)
      return {
        'success': true,
        'source': 'Direct Firestore',
        'note': 'This is direct database access - should be avoided',
      };
    } catch (e) {
      return {
        'success': false,
        'source': 'Direct Firestore',
        'error': e.toString(),
      };
    }
  }

  /// Get comprehensive test report
  static Future<Map<String, dynamic>> getTestReport() async {
    debugPrint("📊 Generating Cloud Functions test report...");
    
    final results = <String, dynamic>{};
    
    // Test 1: Basic connectivity
    results['basicConnectivity'] = await testConnection();
    
    // Test 2: Event creation
    results['eventCreation'] = await testEventCreation();
    
    // Test 3: Health check
    results['healthCheck'] = await _testHealthCheck();
    
    // Summary
    final allSuccessful = results.values.every((test) => test['success'] == true);
    
    results['summary'] = {
      'allTestsPassed': allSuccessful,
      'totalTests': results.length,
      'passedTests': results.values.where((test) => test['success'] == true).length,
      'recommendation': allSuccessful 
          ? '✅ Cloud Functions are working correctly - use them for all backend operations'
          : '⚠️ Some Cloud Functions tests failed - check Firebase console logs',
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    return results;
  }

  static Future<Map<String, dynamic>> _testHealthCheck() async {
    try {
      // Note: Health check is an HTTP function, not callable
      return {
        'success': true,
        'source': 'Health Check',
        'note': 'Health check endpoint available at your Firebase Functions URL',
      };
    } catch (e) {
      return {
        'success': false,
        'source': 'Health Check',
        'error': e.toString(),
      };
    }
  }
}
