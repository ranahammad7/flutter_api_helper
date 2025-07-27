import 'dart:io';

import 'package:flutter_api_helper/flutter_api_helper.dart';
import '../models/user.dart';
import '../models/post.dart';
import '../models/comment.dart';

class ApiService {
  // User operations
  static Future<List<User>> getUsers() async {
    final response = await ApiHelper.get<List<dynamic>>('/users');
    return response.map((json) => User.fromJson(json)).toList();
  }

  static Future<User> getUser(int id) async {
    final response = await ApiHelper.get<Map<String, dynamic>>('/users/$id');
    return User.fromJson(response);
  }

  static Future<User> createUser(User user) async {
    final response = await ApiHelper.post<Map<String, dynamic>>('/users',
        data: user.toJson());
    return User.fromJson(response);
  }

  static Future<User> updateUser(int id, User user) async {
    final response = await ApiHelper.put<Map<String, dynamic>>('/users/$id',
        data: user.toJson());
    return User.fromJson(response);
  }

  static Future<void> deleteUser(int id) async {
    await ApiHelper.delete('/users/$id');
  }

  // Post operations
  static Future<List<Post>> getPosts({bool useCache = true}) async {
    final response = await ApiHelper.get<List<dynamic>>(
      '/posts',
      cache:
          useCache ? const CacheConfig(duration: Duration(minutes: 5)) : null,
    );
    return response.map((json) => Post.fromJson(json)).toList();
  }

  static Future<Post> getPost(int id, {bool useCache = true}) async {
    final response = await ApiHelper.get<Map<String, dynamic>>(
      '/posts/$id',
      cache:
          useCache ? const CacheConfig(duration: Duration(minutes: 5)) : null,
    );
    return Post.fromJson(response);
  }

  static Future<List<Post>> getUserPosts(int userId,
      {bool useCache = true}) async {
    final response = await ApiHelper.get<List<dynamic>>(
      '/users/$userId/posts',
      cache:
          useCache ? const CacheConfig(duration: Duration(minutes: 3)) : null,
    );
    return response.map((json) => Post.fromJson(json)).toList();
  }

  // Comment operations
  static Future<List<Comment>> getPostComments(int postId) async {
    final response =
        await ApiHelper.get<List<dynamic>>('/posts/$postId/comments');
    return response.map((json) => Comment.fromJson(json)).toList();
  }

  // File operations
  static Future<String> uploadFile(
    String filePath, {
    String? description,
    Function(int, int)? onProgress,
  }) async {
    final response = await ApiHelper.uploadFile(
      '/upload',
      File(filePath),
      fieldName: 'file',
      fields: {
        if (description != null) 'description': description,
        'timestamp': DateTime.now().toIso8601String(),
      },
      onProgress: onProgress,
    );
    return response['fileUrl'] ?? '';
  }

  static Future<void> downloadFile(
    String url,
    String savePath, {
    Function(int, int)? onProgress,
  }) async {
    await ApiHelper.downloadFile(
      url,
      savePath,
      onProgress: onProgress,
    );
  }
}
