import 'package:flutter/material.dart';
import 'users_screen.dart';
import 'posts_screen.dart';
import 'upload_screen.dart';
import 'cache_demo_screen.dart';
import 'error_demo_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter API Helper Demo'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildDemoCard(
              context,
              'Users API',
              'GET, POST, PUT, DELETE operations',
              Icons.people,
              Colors.green,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UsersScreen()),
              ),
            ),
            _buildDemoCard(
              context,
              'Posts with Caching',
              'Demonstrates caching features',
              Icons.article,
              Colors.orange,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PostsScreen()),
              ),
            ),
            _buildDemoCard(
              context,
              'File Upload',
              'File upload with progress',
              Icons.upload_file,
              Colors.purple,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UploadScreen()),
              ),
            ),
            _buildDemoCard(
              context,
              'Cache Demo',
              'Cache management utilities',
              Icons.storage,
              Colors.teal,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CacheDemoScreen()),
              ),
            ),
            _buildDemoCard(
              context,
              'Error Handling',
              'Different error scenarios',
              Icons.error_outline,
              Colors.red,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ErrorDemoScreen()),
              ),
            ),
            _buildDemoCard(
              context,
              'ApiBuilder Widget',
              'Widget integration examples',
              Icons.widgets,
              Colors.indigo,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PostsScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
