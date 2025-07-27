import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_api_helper/flutter_api_helper.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([http.Client])
// import 'api_helper_test.mocks.dart';

void main() {
  group('ApiHelper Tests', () {
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient(
        (request) => Future.value(http.Response('{"data": "test"}', 200)),
      );
      ApiHelper.configure(ApiConfig(
        baseUrl: 'https://api.example.com',
        enableLogging: false,
      ));
    });

    test('should make GET request successfully', () async {
      // Arrange
      const responseBody = '{"id": 1, "name": "Test"}';
      when(mockClient.get(
        Uri.parse('https://api.example.com/users'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(responseBody, 200));

      // Act & Assert
      expect(() async {
        await ApiHelper.get('/users');
      }, returnsNormally);
    });

    test('should handle API errors correctly', () async {
      // Arrange
      when(mockClient.get(
        Uri.parse('https://api.example.com/users'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response('Not Found', 404));

      // Act & Assert
      expect(() async {
        await ApiHelper.get('/users');
      }, throwsA(isA<ApiError>()));
    });

    test('should handle network errors', () async {
      // Arrange
      when(mockClient.get(
        Uri.parse('https://api.example.com/users'),
        headers: anyNamed('headers'),
      )).thenThrow(Exception('Network error'));

      // Act & Assert
      expect(() async {
        await ApiHelper.get('/users');
      }, throwsA(isA<ApiError>()));
    });
  });

  group('ApiError Tests', () {
    test('should create API error correctly', () {
      const error = ApiError(
        message: 'Test error',
        statusCode: 400,
        type: ApiErrorType.client,
        isRetryable: false,
      );

      expect(error.message, 'Test error');
      expect(error.statusCode, 400);
      expect(error.type, ApiErrorType.client);
      expect(error.isRetryable, false);
      expect(error.isClientError, true);
      expect(error.isServerError, false);
    });
  });

  group('CacheConfig Tests', () {
    test('should create cache config with default values', () {
      const config = CacheConfig();

      expect(config.duration, const Duration(minutes: 5));
      expect(config.useMemoryCache, true);
      expect(config.useDiskCache, true);
    });

    test('should create cache config with custom values', () {
      const config = CacheConfig(
        duration: Duration(hours: 1),
        keyPrefix: 'test_',
        useMemoryCache: false,
      );

      expect(config.duration, const Duration(hours: 1));
      expect(config.keyPrefix, 'test_');
      expect(config.useMemoryCache, false);
    });
  });

  group('RetryConfig Tests', () {
    test('should create retry config with default values', () {
      const config = RetryConfig();

      expect(config.maxRetries, 3);
      expect(config.retryDelay, const Duration(seconds: 1));
      expect(config.useExponentialBackoff, true);
    });
  });
}
