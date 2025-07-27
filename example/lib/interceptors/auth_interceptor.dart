import 'package:flutter_api_helper/flutter_api_helper.dart';
import '../services/token_storage.dart';
import '../services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

class AuthInterceptor extends ApiInterceptor {
  @override
  Future<void> onRequest(
    String method,
    String url,
    Map<String, String>? headers,
    dynamic data,
  ) async {
    // Add auth token to requests
    final token = await TokenStorage.getToken();
    if (token != null) {
      headers?['Authorization'] = 'Bearer $token';
    }
  }

  @override
  Future<void> onResponse(http.Response response) async {
    // Handle token expiration
    if (response.statusCode == 401) {
      final refreshed = await AuthService.refreshToken();
      if (!refreshed) {
        // Redirect to login or show auth error
        await AuthService.logout();
      }
    }
  }

  @override
  Future<void> onError(dynamic error) async {
    String errorMessage;
    if (error is ApiError) {
      errorMessage = 'API Error (${error.type}): ${error.message}';
    } else {
      errorMessage = 'API Error: $error';
    }
    developer.log(errorMessage);
  }
}
