import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'models/api_error.dart';
import 'models/cache_config.dart';
import 'models/retry_config.dart';
import 'models/api_config.dart';
import 'cache/cache_manager.dart';
import 'interceptors/interceptor.dart';

/// Main API Helper class that handles all HTTP operations
class ApiHelper {
  static ApiHelper? _instance;
  static ApiHelper get instance => _instance ??= ApiHelper._();

  ApiHelper._();

  ApiConfig _config = const ApiConfig();
  // final CacheManager _cacheManager = CacheManager();
  final CacheManager _cacheManager = CacheManager.instance;

  final List<ApiInterceptor> _interceptors = [];
  final http.Client _client = http.Client();

  /// Configure the API Helper with global settings
  static void configure(ApiConfig config) {
    instance._config = config;
    if (config.enableLogging) {
      instance.addInterceptor(LoggingInterceptor());
    }
  }

  /// Add an interceptor
  void addInterceptor(ApiInterceptor interceptor) {
    _interceptors.add(interceptor);
  }

  /// Remove an interceptor
  void removeInterceptor(ApiInterceptor interceptor) {
    _interceptors.remove(interceptor);
  }

  /// Make a GET request
  static Future<T> get<T>(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
    CacheConfig? cache,
    RetryConfig? retry,
    Duration? timeout,
  }) async {
    return instance._makeRequest<T>(
      'GET',
      endpoint,
      headers: headers,
      queryParams: queryParams,
      cache: cache,
      retry: retry,
      timeout: timeout,
    );
  }

  /// Make a POST request
  static Future<T> post<T>(
    String endpoint, {
    dynamic data,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
    RetryConfig? retry,
    Duration? timeout,
  }) async {
    return instance._makeRequest<T>(
      'POST',
      endpoint,
      data: data,
      headers: headers,
      queryParams: queryParams,
      retry: retry,
      timeout: timeout,
    );
  }

  /// Make a PUT request
  static Future<T> put<T>(
    String endpoint, {
    dynamic data,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
    RetryConfig? retry,
    Duration? timeout,
  }) async {
    return instance._makeRequest<T>(
      'PUT',
      endpoint,
      data: data,
      headers: headers,
      queryParams: queryParams,
      retry: retry,
      timeout: timeout,
    );
  }

  /// Make a PATCH request
  static Future<T> patch<T>(
    String endpoint, {
    dynamic data,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
    RetryConfig? retry,
    Duration? timeout,
  }) async {
    return instance._makeRequest<T>(
      'PATCH',
      endpoint,
      data: data,
      headers: headers,
      queryParams: queryParams,
      retry: retry,
      timeout: timeout,
    );
  }

  /// Make a DELETE request
  static Future<T> delete<T>(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
    RetryConfig? retry,
    Duration? timeout,
  }) async {
    return instance._makeRequest<T>(
      'DELETE',
      endpoint,
      headers: headers,
      queryParams: queryParams,
      retry: retry,
      timeout: timeout,
    );
  }

  /// Upload a file
  static Future<T> uploadFile<T>(
    String endpoint,
    File file, {
    String fieldName = 'file',
    Map<String, String>? fields,
    Map<String, String>? headers,
    void Function(int sent, int total)? onProgress,
  }) async {
    return instance._uploadFile<T>(
      endpoint,
      file,
      fieldName: fieldName,
      fields: fields,
      headers: headers,
      onProgress: onProgress,
    );
  }

  /// Download a file
  static Future<void> downloadFile(
    String endpoint,
    String savePath, {
    Map<String, String>? headers,
    void Function(int received, int total)? onProgress,
  }) async {
    return instance._downloadFile(
      endpoint,
      savePath,
      headers: headers,
      onProgress: onProgress,
    );
  }

  /// Clear all cache
  static Future<void> clearCache() async {
    await instance._cacheManager.clear();
  }

  /// Clear specific cache
  static Future<void> clearCacheForUrl(String url) async {
    await instance._cacheManager.remove(url);
  }

  /// Check network connectivity
  static Future<bool> hasNetwork() async {
    final connectivity = await Connectivity().checkConnectivity();
    return connectivity != ConnectivityResult.none;
  }

  /// Main request method
  Future<T> _makeRequest<T>(
    String method,
    String endpoint, {
    dynamic data,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
    CacheConfig? cache,
    RetryConfig? retry,
    Duration? timeout,
  }) async {
    // Build URL
    final url = _buildUrl(endpoint, queryParams);

    // Check cache first (for GET requests)
    if (method == 'GET' && cache != null) {
      final cachedResponse = await _cacheManager.get(url);
      if (cachedResponse != null) {
        return _parseResponse<T>(cachedResponse);
      }
    }

    // Check network connectivity
    if (!await hasNetwork()) {
      throw const ApiError(
        message: 'No internet connection',
        type: ApiErrorType.network,
      );
    }

    // Apply retry logic
    final retryConfig = retry ?? _config.retryConfig;
    return _executeWithRetry<T>(
      () => _executeRequest<T>(method, url,
          data: data, headers: headers, timeout: timeout),
      retryConfig,
    );
  }

  /// Execute request with retry logic
  Future<T> _executeWithRetry<T>(
    Future<T> Function() request,
    RetryConfig? retryConfig,
  ) async {
    if (retryConfig == null) {
      return await request();
    }

    int attempts = 0;
    while (attempts <= retryConfig.maxRetries) {
      try {
        return await request();
      } catch (e) {
        attempts++;

        if (attempts > retryConfig.maxRetries) {
          rethrow;
        }

        // Check if error is retryable
        if (e is ApiError && !e.isRetryable) {
          rethrow;
        }

        // Wait before retry
        await Future.delayed(
          Duration(
            milliseconds: retryConfig.retryDelay.inMilliseconds * attempts,
          ),
        );
      }
    }

    throw const ApiError(
      message: 'Max retries exceeded',
      type: ApiErrorType.timeout,
    );
  }

  /// Execute the actual HTTP request
  Future<T> _executeRequest<T>(
    String method,
    String url, {
    dynamic data,
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    // Apply interceptors (request)
    for (final interceptor in _interceptors) {
      await interceptor.onRequest(method, url, headers, data);
    }

    // Prepare headers
    final requestHeaders = <String, String>{
      'Content-Type': 'application/json',
      ...?_config.defaultHeaders,
      ...?headers,
    };

    // Add authentication token
    if (_config.getToken != null) {
      try {
        final token = await _config.getToken!();
        if (token != null) {
          requestHeaders['Authorization'] = 'Bearer $token';
        }
      } catch (e) {
        debugPrint('Error getting token: $e');
      }
    }

    // Make the request
    http.Response response;
    final timeoutDuration = timeout ?? _config.timeout;

    try {
      switch (method.toUpperCase()) {
        case 'GET':
          response = await _client
              .get(
                Uri.parse(url),
                headers: requestHeaders,
              )
              .timeout(timeoutDuration);
          break;
        case 'POST':
          response = await _client
              .post(
                Uri.parse(url),
                headers: requestHeaders,
                body: data != null ? jsonEncode(data) : null,
              )
              .timeout(timeoutDuration);
          break;
        case 'PUT':
          response = await _client
              .put(
                Uri.parse(url),
                headers: requestHeaders,
                body: data != null ? jsonEncode(data) : null,
              )
              .timeout(timeoutDuration);
          break;
        case 'PATCH':
          response = await _client
              .patch(
                Uri.parse(url),
                headers: requestHeaders,
                body: data != null ? jsonEncode(data) : null,
              )
              .timeout(timeoutDuration);
          break;
        case 'DELETE':
          response = await _client
              .delete(
                Uri.parse(url),
                headers: requestHeaders,
              )
              .timeout(timeoutDuration);
          break;
        default:
          throw ApiError(
            message: 'Unsupported HTTP method: $method',
            type: ApiErrorType.unknown,
          );
      }
    } on TimeoutException {
      throw const ApiError(
        message: 'Request timeout',
        type: ApiErrorType.timeout,
      );
    } on SocketException {
      throw const ApiError(
        message: 'Network error',
        type: ApiErrorType.network,
      );
    } catch (e) {
      throw ApiError(
        message: 'Request failed: $e',
        type: ApiErrorType.unknown,
      );
    }

    // Apply interceptors (response)
    for (final interceptor in _interceptors) {
      await interceptor.onResponse(response);
    }

    // Handle response
    await _handleResponse(response);

    // Parse and return response
    final result = _parseResponse<T>(response.body);

    // Cache the response if needed (for GET requests)
    if (method == 'GET' && _config.cacheConfig != null) {
      await _cacheManager.set(url, response.body, _config.cacheConfig!);
    }

    return result;
  }

  /// Handle HTTP response and check for errors
  Future<void> _handleResponse(http.Response response) async {
    // Handle token expiration
    if (response.statusCode == 401 && _config.onTokenExpired != null) {
      try {
        await _config.onTokenExpired!();
      } catch (e) {
        debugPrint('Error refreshing token: $e');
      }
    }

    // Handle different status codes
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return; // Success
    }

    ApiErrorType errorType;
    bool isRetryable = false;

    if (response.statusCode >= 400 && response.statusCode < 500) {
      errorType = ApiErrorType.client;
      isRetryable = response.statusCode == 429; // Rate limit
    } else if (response.statusCode >= 500) {
      errorType = ApiErrorType.server;
      isRetryable = true;
    } else {
      errorType = ApiErrorType.unknown;
    }

    String message = 'Request failed with status ${response.statusCode}';

    try {
      final errorData = jsonDecode(response.body);
      if (errorData is Map<String, dynamic>) {
        message = errorData['message'] ??
            errorData['error'] ??
            errorData['detail'] ??
            message;
      }
    } catch (e) {
      // Use default message if parsing fails
    }

    final error = ApiError(
      message: message,
      statusCode: response.statusCode,
      type: errorType,
      isRetryable: isRetryable,
      responseBody: response.body,
    );

    // Call error handler
    if (_config.onError != null) {
      _config.onError!(error);
    }

    throw error;
  }

  /// Parse response to the expected type
  T _parseResponse<T>(String responseBody) {
    if (T == String) {
      return responseBody as T;
    }

    try {
      final decodedJson = jsonDecode(responseBody);

      if (T == dynamic) {
        return decodedJson as T;
      }

      // Handle common types
      if (decodedJson is T) {
        return decodedJson;
      }

      return decodedJson as T;
    } catch (e) {
      throw ApiError(
        message: 'Failed to parse response: $e',
        type: ApiErrorType.parsing,
        responseBody: responseBody,
      );
    }
  }

  /// Build URL with query parameters
  String _buildUrl(String endpoint, Map<String, dynamic>? queryParams) {
    final baseUrl = _config.baseUrl?.replaceAll(RegExp(r'/$'), '') ?? '';
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';

    String url = '$baseUrl$cleanEndpoint';

    if (queryParams != null && queryParams.isNotEmpty) {
      final queryString = queryParams.entries
          .where((entry) => entry.value != null)
          .map((entry) =>
              '${entry.key}=${Uri.encodeComponent(entry.value.toString())}')
          .join('&');

      url += '?$queryString';
    }

    return url;
  }

  /// Upload file implementation
  Future<T> _uploadFile<T>(
    String endpoint,
    File file, {
    String fieldName = 'file',
    Map<String, String>? fields,
    Map<String, String>? headers,
    void Function(int sent, int total)? onProgress,
  }) async {
    final url = _buildUrl(endpoint, null);

    final request = http.MultipartRequest('POST', Uri.parse(url));

    // Add headers
    if (_config.defaultHeaders != null) {
      request.headers.addAll(_config.defaultHeaders!);
    }
    if (headers != null) {
      request.headers.addAll(headers);
    }

    // Add authentication token
    if (_config.getToken != null) {
      try {
        final token = await _config.getToken!();
        if (token != null) {
          request.headers['Authorization'] = 'Bearer $token';
        }
      } catch (e) {
        debugPrint('Error getting token: $e');
      }
    }

    // Add file
    request.files.add(await http.MultipartFile.fromPath(fieldName, file.path));

    // Add fields
    if (fields != null) {
      request.fields.addAll(fields);
    }

    // Send request
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    await _handleResponse(response);
    return _parseResponse<T>(response.body);
  }

  /// Download file implementation
  Future<void> _downloadFile(
    String endpoint,
    String savePath, {
    Map<String, String>? headers,
    void Function(int received, int total)? onProgress,
  }) async {
    final url = _buildUrl(endpoint, null);

    final requestHeaders = <String, String>{
      ...?_config.defaultHeaders,
      ...?headers,
    };

    // Add authentication token
    if (_config.getToken != null) {
      try {
        final token = await _config.getToken!();
        if (token != null) {
          requestHeaders['Authorization'] = 'Bearer $token';
        }
      } catch (e) {
        debugPrint('Error getting token: $e');
      }
    }

    final request = http.Request('GET', Uri.parse(url));
    request.headers.addAll(requestHeaders);

    final streamedResponse = await _client.send(request);

    if (streamedResponse.statusCode != 200) {
      throw ApiError(
        message: 'Download failed with status ${streamedResponse.statusCode}',
        statusCode: streamedResponse.statusCode,
        type: ApiErrorType.server,
      );
    }

    final file = File(savePath);
    final sink = file.openWrite();

    int received = 0;
    final total = streamedResponse.contentLength ?? 0;

    await for (final chunk in streamedResponse.stream) {
      sink.add(chunk);
      received += chunk.length;

      if (onProgress != null) {
        onProgress(received, total);
      }
    }

    await sink.close();
  }
}
