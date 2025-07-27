import 'package:flutter/material.dart';
import 'package:flutter_api_helper/flutter_api_helper.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  double _uploadProgress = 0.0;
  double _downloadProgress = 0.0;
  bool _isUploading = false;
  bool _isDownloading = false;
  String? _uploadResult;
  String? _downloadPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Operations Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Upload Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'File Upload',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    if (_isUploading) ...[
                      LinearProgressIndicator(value: _uploadProgress),
                      const SizedBox(height: 8),
                      Text('Uploading: ${(_uploadProgress * 100).toInt()}%'),
                    ],
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isUploading ? null : _simulateUpload,
                      icon: const Icon(Icons.upload),
                      label: const Text('Simulate Upload'),
                    ),
                    if (_uploadResult != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Result: $_uploadResult',
                        style: const TextStyle(color: Colors.green),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Download Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'File Download',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    if (_isDownloading) ...[
                      LinearProgressIndicator(value: _downloadProgress),
                      const SizedBox(height: 8),
                      Text(
                          'Downloading: ${(_downloadProgress * 100).toInt()}%'),
                    ],
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isDownloading ? null : _simulateDownload,
                      icon: const Icon(Icons.download),
                      label: const Text('Simulate Download'),
                    ),
                    if (_downloadPath != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Downloaded to: $_downloadPath',
                        style: const TextStyle(color: Colors.green),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const Spacer(),

            // Network Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'API Helper Features Demo',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text('• Automatic retry with exponential backoff'),
                    const Text('• Smart caching (memory + disk)'),
                    const Text('• Progress tracking for uploads/downloads'),
                    const Text('• Network connectivity awareness'),
                    const Text('• Comprehensive error handling'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Simulate file upload with progress
  void _simulateUpload() async {
    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _uploadResult = null;
    });

    try {
      // Simulate upload progress
      for (int i = 0; i <= 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 200));
        setState(() {
          _uploadProgress = i / 100;
        });
      }

      // Simulate actual API call
      final response = await ApiHelper.post(
        '/posts', // Using JSONPlaceholder endpoint
        data: {
          'title': 'Uploaded File',
          'body': 'File content simulation',
          'userId': 1,
        },
      );

      setState(() {
        _uploadResult = 'Upload successful! ID: ${response['id']}';
      });
    } catch (e) {
      setState(() {
        _uploadResult = 'Upload failed: $e';
      });
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  // Simulate file download with progress
  void _simulateDownload() async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
      _downloadPath = null;
    });

    try {
      // Simulate download progress
      for (int i = 0; i <= 100; i += 15) {
        await Future.delayed(const Duration(milliseconds: 300));
        setState(() {
          _downloadProgress = i / 100;
        });
      }

      // Simulate actual API call
      await ApiHelper.get('/posts/1'); // Fetch a post

      setState(() {
        _downloadPath = '/downloads/simulated_file.json';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isDownloading = false;
      });
    }
  }
}
