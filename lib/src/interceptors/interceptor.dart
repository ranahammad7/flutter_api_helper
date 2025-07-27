import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// Base interceptor class
abstract class ApiInterceptor {
  /// Called before request is sent
  Future<void> onRequest(
    String method,
    String url,
    Map<String, String>? headers,
    dynamic data,
  ) async {}

  /// Called after response is received
  Future<void> onResponse(http.Response response) async {}

  /// Called when an error occurs
  Future<void> onError(dynamic error) async {}
}

/// Logging interceptor
class LoggingInterceptor extends ApiInterceptor {
  final bool logHeaders;
  final bool logBody;
  final bool logResponse;

  LoggingInterceptor({
    this.logHeaders = true,
    this.logBody = true,
    this.logResponse = false,
  });

  @override
  Future<void> onRequest(
    String method,
    String url,
    Map<String, String>? headers,
    dynamic data,
  ) async {
    if (kDebugMode) {
      debugPrint('🚀 API Request: $method $url');

      if (logHeaders && headers != null && headers.isNotEmpty) {
        debugPrint('📋 Headers: $headers');
      }

      if (logBody && data != null) {
        debugPrint('📦 Body: $data');
      }
    }
  }

  @override
  Future<void> onResponse(http.Response response) async {
    if (kDebugMode) {
      final statusEmoji =
          response.statusCode >= 200 && response.statusCode < 300 ? '✅' : '❌';
      debugPrint(
          '$statusEmoji Response: ${response.statusCode} ${response.request?.url}');

      if (logResponse) {
        debugPrint('📄 Response Body: ${response.body}');
      }
    }
  }

  @override
  Future<void> onError(dynamic error) async {
    if (kDebugMode) {
      debugPrint('💥 API Error: $error');
    }
  }
}

/// Token refresh interceptor
class TokenRefreshInterceptor extends ApiInterceptor {
  final Future<String?> Function() getToken;
  final Future<void> Function() refreshToken;

  TokenRefreshInterceptor({
    required this.getToken,
    required this.refreshToken,
  });

  @override
  Future<void> onRequest(
    String method,
    String url,
    Map<String, String>? headers,
    dynamic data,
  ) async {
    try {
      final token = await getToken();
      if (token != null && headers != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      debugPrint('Error getting token in interceptor: $e');
    }
  }

  @override
  Future<void> onResponse(http.Response response) async {
    if (response.statusCode == 401) {
      try {
        await refreshToken();
      } catch (e) {
        debugPrint('Error refreshing token: $e');
      }
    }
  }
}
