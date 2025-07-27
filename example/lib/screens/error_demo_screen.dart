import 'package:flutter/material.dart';
import 'package:flutter_api_helper/flutter_api_helper.dart';

class ErrorDemoScreen extends StatefulWidget {
  @override
  _ErrorDemoScreenState createState() => _ErrorDemoScreenState();
}

class _ErrorDemoScreenState extends State<ErrorDemoScreen> {
  String? _lastError;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error Handling Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Error Scenarios',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildErrorButton(
                      'Network Error',
                      'Simulate network connectivity issues',
                      Icons.signal_wifi_off,
                      Colors.orange,
                      () => _simulateError('network'),
                    ),
                    const SizedBox(height: 8),
                    _buildErrorButton(
                      'Server Error (500)',
                      'Simulate internal server error',
                      Icons.error,
                      Colors.red,
                      () => _simulateError('server'),
                    ),
                    const SizedBox(height: 8),
                    _buildErrorButton(
                      'Not Found (404)',
                      'Simulate resource not found',
                      Icons.search_off,
                      Colors.amber,
                      () => _simulateError('notfound'),
                    ),
                    const SizedBox(height: 8),
                    _buildErrorButton(
                      'Timeout Error',
                      'Simulate request timeout',
                      Icons.access_time,
                      Colors.blue,
                      () => _simulateError('timeout'),
                    ),
                    const SizedBox(height: 8),
                    _buildErrorButton(
                      'Auth Error (401)',
                      'Simulate authentication failure',
                      Icons.lock,
                      Colors.purple,
                      () => _simulateError('auth'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Making request...'),
                    ],
                  ),
                ),
              ),
            if (_lastError != null && !_isLoading)
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.error, color: Colors.red),
                          SizedBox(width: 8),
                          Text(
                            'Error Result',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(_lastError!),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () => setState(() => _lastError = null),
                        icon: const Icon(Icons.clear),
                        label: const Text('Clear'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const Spacer(),
            Card(
              color: Colors.blue.shade50,
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'About Error Handling',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Flutter API Helper provides detailed error classification:\n\n'
                      '• Network errors for connectivity issues\n'
                      '• Server errors for 5xx responses\n'
                      '• Client errors for 4xx responses\n'
                      '• Authentication errors for auth failures\n'
                      '• Timeout errors for slow requests\n'
                      '• Parsing errors for malformed JSON',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorButton(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.1),
          foregroundColor: color,
          elevation: 0,
          padding: const EdgeInsets.all(16),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: color.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _simulateError(String errorType) async {
    setState(() {
      _isLoading = true;
      _lastError = null;
    });

    try {
      if (errorType == 'timeout') {
        // Simulate timeout with short timeout setting
        await ApiHelper.get(
          '/posts',
          retry: const RetryConfig(maxRetries: 0),
        );
      } else {
        String endpoint;
        switch (errorType) {
          case 'network':
            endpoint = 'https://httpstat.us/500?sleep=10000';
            break;
          case 'server':
            endpoint = 'https://httpstat.us/500';
            break;
          case 'notfound':
            endpoint = '/nonexistent-endpoint';
            break;
          case 'auth':
            endpoint = 'https://httpstat.us/401';
            break;
          default:
            endpoint = '/posts';
        }

        await ApiHelper.get(
          endpoint,
          retry: const RetryConfig(maxRetries: 0),
        );
      }

      setState(() {
        _isLoading = false;
        _lastError = 'Unexpected success - no error occurred';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        if (e is ApiError) {
          _lastError = '''
Error Type: ${e.type.toString().split('.').last}
Status Code: ${e.statusCode ?? 'N/A'}
Message: ${e.message}
Timestamp: ${DateTime.now().toString().substring(11, 19)}
''';
        } else {
          _lastError = 'Unexpected error: $e';
        }
      });
    }
  }
}
