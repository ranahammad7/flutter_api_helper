import 'package:flutter/material.dart';
import 'package:flutter_api_helper/flutter_api_helper.dart';

class CacheDemoScreen extends StatefulWidget {
  const CacheDemoScreen({super.key});

  @override
  _CacheDemoScreenState createState() => _CacheDemoScreenState();
}

class _CacheDemoScreenState extends State<CacheDemoScreen> {
  String? _lastFetchTime;
  Map<String, dynamic>? _data;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cache Demo'),
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
                      'Cache Operations',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : () => _fetchData(useCache: true),
                            child: const Text('Fetch (Cached)'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : () => _fetchData(useCache: false),
                            child: const Text('Fetch (No Cache)'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _clearAllCache,
                            child: const Text('Clear All Cache'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _clearUrlCache,
                            child: const Text('Clear URL Cache'),
                          ),
                        ),
                      ],
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
                      Text('Loading...'),
                    ],
                  ),
                ),
              ),
            if (_data != null && !_isLoading) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.access_time, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            'Last Fetch: $_lastFetchTime',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Data Preview:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _data.toString(),
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const Spacer(),
            Card(
              color: Colors.amber.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.amber.shade700),
                        const SizedBox(width: 8),
                        const Text(
                          'How it works:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• "Fetch (Cached)" will use cached data if available\n'
                      '• "Fetch (No Cache)" always fetches fresh data\n'
                      '• Cache expires after 2 minutes in this demo\n'
                      '• Watch the timestamps to see caching in action',
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

  Future<void> _fetchData({required bool useCache}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await ApiHelper.get(
        '/posts/1',
        cache:
            useCache ? const CacheConfig(duration: Duration(minutes: 2)) : null,
      );

      setState(() {
        _data = data;
        _lastFetchTime = DateTime.now().toString().substring(11, 19);
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(useCache ? 'Data fetched (cached)' : 'Data fetched (fresh)'),
          backgroundColor: useCache ? Colors.green : Colors.blue,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _clearAllCache() async {
    await ApiHelper.clearCache();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All cache cleared')),
    );
  }

  Future<void> _clearUrlCache() async {
    await ApiHelper.clearCacheForUrl('/posts/1');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cache cleared for /posts/1')),
    );
  }
}
