import 'package:flutter/material.dart';
import '../services/cloud_functions_test_service.dart';

/// Widget to test and verify Cloud Functions connectivity

class CloudFunctionsTestWidget extends StatefulWidget {
  const CloudFunctionsTestWidget({super.key});

  @override
  State<CloudFunctionsTestWidget> createState() => _CloudFunctionsTestWidgetState();
}

class _CloudFunctionsTestWidgetState extends State<CloudFunctionsTestWidget> {
  Map<String, dynamic>? _testResults;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloud Functions Test'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🧪 Backend Verification',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Use this tool to verify that your app is using Cloud Functions instead of direct Firestore access.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
           
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _runBasicTest,
              icon: const Icon(Icons.wifi_tethering),
              label: const Text('Test Basic Connectivity'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 8),
            
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _runEventCreationTest,
              icon: const Icon(Icons.event),
              label: const Text('Test Event Creation'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 8),
            
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _runFullTestSuite,
              icon: const Icon(Icons.assessment),
              label: const Text('Run Full Test Suite'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 16),
            
            
            if (_isLoading)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 8),
                    Text('Testing Cloud Functions...'),
                  ],
                ),
              ),
            
          
            if (_testResults != null && !_isLoading)
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _testResults!['success'] == true 
                                  ? Icons.check_circle 
                                  : Icons.error,
                              color: _testResults!['success'] == true 
                                  ? Colors.green 
                                  : Colors.red,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Test Results',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: SingleChildScrollView(
                            child: _buildResultsTree(_testResults!),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsTree(Map<String, dynamic> data, [int indent = 0]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: data.entries.map((entry) {
        final key = entry.key;
        final value = entry.value;
        
        return Padding(
          padding: EdgeInsets.only(left: indent * 16.0, bottom: 4),
          child: value is Map<String, dynamic>
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      key,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(value),
                      ),
                    ),
                    _buildResultsTree(value, indent + 1),
                  ],
                )
              : RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black87),
                    children: [
                      TextSpan(
                        text: '$key: ',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      TextSpan(
                        text: value.toString(),
                        style: TextStyle(
                          color: _getValueColor(key, value),
                          fontFamily: key == 'error' ? 'monospace' : null,
                        ),
                      ),
                    ],
                  ),
                ),
        );
      }).toList(),
    );
  }

  Color _getStatusColor(Map<String, dynamic> data) {
    if (data['success'] == true) return Colors.green;
    if (data['success'] == false) return Colors.red;
    return Colors.blue;
  }

  Color _getValueColor(String key, dynamic value) {
    if (key == 'success') {
      return value == true ? Colors.green : Colors.red;
    }
    if (key == 'error') return Colors.red;
    if (key == 'source' && value.toString().contains('Cloud Functions')) {
      return Colors.green;
    }
    return Colors.black87;
  }

  Future<void> _runBasicTest() async {
    setState(() {
      _isLoading = true;
      _testResults = null;
    });

    try {
      final result = await CloudFunctionsTestService.testConnection(
        message: 'Testing from Flutter App UI'
      );
      
      setState(() {
        _testResults = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _testResults = {
          'success': false,
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        };
        _isLoading = false;
      });
    }
  }

  Future<void> _runEventCreationTest() async {
    setState(() {
      _isLoading = true;
      _testResults = null;
    });

    try {
      final result = await CloudFunctionsTestService.testEventCreation();
      
      setState(() {
        _testResults = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _testResults = {
          'success': false,
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        };
        _isLoading = false;
      });
    }
  }

  Future<void> _runFullTestSuite() async {
    setState(() {
      _isLoading = true;
      _testResults = null;
    });

    try {
      final result = await CloudFunctionsTestService.getTestReport();
      
      setState(() {
        _testResults = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _testResults = {
          'success': false,
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        };
        _isLoading = false;
      });
    }
  }
}
