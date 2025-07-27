import 'package:example/services/auth_service.dart';
import 'package:flutter_api_helper/flutter_api_helper.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

class LoggingInterceptor extends ApiInterceptor {
  @override
  Future<void> onRequest(
    String method,
    String url,
    Map<String, String>? headers,
    dynamic data,
  ) async {
    developer.log(
      '→ $method $url',
      name: 'API Request',
      level: 800,
    );

    if (headers != null && headers.isNotEmpty) {
      developer.log(
        'Headers: $headers',
        name: 'API Request',
        level: 800,
      );
    }

    if (data != null) {
      developer.log(
        'Body: $data',
        name: 'API Request',
        level: 800,
      );
    }
  }

  @override
  Future<void> onResponse(http.Response response) async {
    developer.log(
      '← ${response.statusCode} ${response.request?.url}',
      name: 'API Response',
      level: 800,
    );

    if (response.body.isNotEmpty) {
      developer.log(
        'Response: ${response.body.length > 500 ? '${response.body.substring(0, 500)}...' : response.body}',
        name: 'API Response',
        level: 800,
      );
    }
  }

  @override
  Future<void> onError(dynamic error) async {
    if (error is ApiError && error.type == ApiErrorType.authentication) {
      await AuthService.logout();
    }
  }
}
