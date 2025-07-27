import 'package:flutter/material.dart';
import 'package:flutter_api_helper/flutter_api_helper.dart';
import '../models/user.dart';
import '../models/post.dart';

class UserDetailScreen extends StatelessWidget {
  final User user;

  const UserDetailScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(user.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editUser(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserInfoCard(),
            const SizedBox(height: 16),
            _buildAddressCard(),
            const SizedBox(height: 16),
            _buildCompanyCard(),
            const SizedBox(height: 16),
            _buildUserPostsCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.person, 'Name', user.name),
            _buildInfoRow(Icons.alternate_email, 'Username', user.username),
            _buildInfoRow(Icons.email, 'Email', user.email),
            _buildInfoRow(Icons.phone, 'Phone', user.phone),
            _buildInfoRow(Icons.web, 'Website', user.website),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard() {
    if (user.address == null) return const SizedBox.shrink();

    final address = user.address!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Address',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
                Icons.home, 'Street', '${address.street} ${address.suite}'),
            _buildInfoRow(Icons.location_city, 'City', address.city),
            _buildInfoRow(Icons.local_post_office, 'Zipcode', address.zipcode),
            if (address.geo != null)
              _buildInfoRow(Icons.location_on, 'Coordinates',
                  '${address.geo!.lat}, ${address.geo!.lng}'),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyCard() {
    if (user.company == null) return const SizedBox.shrink();

    final company = user.company!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Company',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.business, 'Name', company.name),
            _buildInfoRow(Icons.campaign, 'Catch Phrase', company.catchPhrase),
            _buildInfoRow(Icons.work, 'Business', company.bs),
          ],
        ),
      ),
    );
  }

  Widget _buildUserPostsCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Posts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ApiBuilder<List<dynamic>>(
              future: ApiHelper.get('/users/${user.id}/posts'),
              builder: (posts) {
                if (posts.isEmpty) {
                  return const Text('No posts found');
                }

                return Column(
                  children: posts.take(3).map((postJson) {
                    final post = Post.fromJson(postJson);
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: Text('${post.id}'),
                      ),
                      title: Text(
                        post.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        post.body,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => _showPostDetail(context, post),
                    );
                  }).toList(),
                );
              },
              loading: const Center(child: CircularProgressIndicator()),
              error: (error) => Text('Error loading posts: ${error.message}'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _editUser(BuildContext context) {
    // Navigate to edit user screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit user functionality would go here')),
    );
  }

  void _showPostDetail(BuildContext context, Post post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Post ${post.id}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                post.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(post.body),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
