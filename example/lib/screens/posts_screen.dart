import 'package:flutter/material.dart';
import 'package:flutter_api_helper/flutter_api_helper.dart';
import '../models/post.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  _PostsScreenState createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  bool _useCache = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts with Caching'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () async {
              await ApiHelper.clearCache();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared!')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.storage, color: Colors.blue),
                  const SizedBox(width: 12),
                  const Text('Use Cache:'),
                  const Spacer(),
                  Switch(
                    value: _useCache,
                    onChanged: (value) => setState(() => _useCache = value),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ApiBuilder<List<dynamic>>(
              future: ApiHelper.get(
                '/posts',
                cache: _useCache
                    ? const CacheConfig(duration: Duration(minutes: 5))
                    : null,
              ),
              builder: (posts) {
                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = Post.fromJson(posts[index]);
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: ExpansionTile(
                        title: Text(
                          post.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('Post ID: ${post.id}'),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(post.body),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(_useCache
                        ? 'Loading (with cache)...'
                        : 'Loading (no cache)...'),
                  ],
                ),
              ),
              error: (error) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: ${error.message}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => setState(() {}),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
