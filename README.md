# Flutter API Helper

[![pub package](https://img.shields.io/pub/v/flutter_api_helper.svg)](https://pub.dev/packages/flutter_api_helper)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub stars](https://img.shields.io/github/stars/ranahammad7/flutter_api_helper.svg?style=social)](https://github.com/ranahammad7/flutter_api_helper)
[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=flat&logo=Flutter&logoColor=white)](https://flutter.dev)

<div align="center">
  <h3>🚀 A powerful, feature-rich HTTP client for Flutter applications</h3>
  <p><em>Built-in caching • Smart retry logic • Seamless widget integration</em></p>
</div>

---

## ✨ Features Overview

<div align="center">
  <img src="https://github.com/ranahammad7/flutter_api_helper/blob/main/assets/features-overview.png?raw=true" alt="Flutter API Helper Features" width="100%">
</div>

<br>

<table>
<tr>
<td width="50%">

✅ **Simple API** - Intuitive methods for all HTTP operations  
✅ **Smart Caching** - Memory and disk caching with configurable TTL  
✅ **Auto Retry** - Exponential backoff for failed requests  
✅ **Token Management** - Automatic token refresh and injection  
✅ **File Operations** - Upload/download with progress tracking  

</td>
<td width="50%">

✅ **Network Aware** - Built-in connectivity checking  
✅ **Widget Integration** - Ready-to-use Flutter widgets  
✅ **Type Safe** - Full generic type support  
✅ **Interceptors** - Custom request/response processing  
✅ **Error Handling** - Comprehensive error types and handling  

</td>
</tr>
</table>

---

## 🎯 Why Choose Flutter API Helper?

<div align="center">

| 🆚 Comparison | Built-in HTTP | **Flutter API Helper** |
|---------------|---------------|-------------------------|
| **Setup** | Complex boilerplate | ✨ One-line configuration |
| **Caching** | Manual implementation | 🧠 Smart auto-caching |
| **Retries** | Custom retry logic | 🔄 Exponential backoff |
| **Errors** | Generic exceptions | 🛡️ Typed error handling |
| **Files** | Complex multipart | 📁 Simple upload/download |
| **Widgets** | Custom FutureBuilder | 🎯 Ready ApiBuilder |

</div>

---

## 🚀 Quick Start

### Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_api_helper: ^1.0.0
```

Then run:
```bash
flutter pub get
```

### ⚡ 30-Second Setup

```dart
import 'package:flutter_api_helper/flutter_api_helper.dart';

void main() {
  // 🔧 Configure once, use everywhere
  ApiHelper.configure(
    ApiConfig(
      baseUrl: 'https://api.yourapp.com',
      enableLogging: true,
      timeout: Duration(seconds: 30),
      // 🧠 Smart caching out of the box
      cacheConfig: CacheConfig(duration: Duration(minutes: 5)),
      // 🔄 Auto-retry with exponential backoff
      retryConfig: RetryConfig(maxRetries: 3),
    ),
  );
  
  runApp(MyApp());
}
```

---

## 📱 Usage Examples

### 🌐 Basic HTTP Operations

```dart
// GET request with automatic type casting
final users = await ApiHelper.get<List<User>>('/users');

// POST request with smart error handling
final newUser = await ApiHelper.post('/users', data: {
  'name': 'John Doe',
  'email': 'john@example.com',
});

// PUT request with caching
final updatedUser = await ApiHelper.put('/users/1', 
  data: {'name': 'Jane Doe'},
  cache: CacheConfig(duration: Duration(minutes: 10)),
);

// DELETE request with retry logic
await ApiHelper.delete('/users/1',
  retry: RetryConfig(maxRetries: 5),
);
```

### 🎯 Flutter Widget Integration

Transform your UI with the **ApiBuilder** widget:

```dart
class UsersList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ApiBuilder<List<User>>(
      future: ApiHelper.get('/users'),
      builder: (users) => ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return ListTile(
            leading: CircleAvatar(child: Text(user.name[0])),
            title: Text(user.name),
            subtitle: Text(user.email),
          );
        },
      ),
      loading: Center(child: CircularProgressIndicator()),
      error: (error) => ErrorWidget('Failed to load users: ${error.message}'),
      empty: Center(child: Text('No users found')),
    );
  }
}
```

### 💾 Smart Caching

```dart
// 🧠 Cache response for 10 minutes
final posts = await ApiHelper.get(
  '/posts',
  cache: CacheConfig(duration: Duration(minutes: 10)),
);

// 🗑️ Clear cache when needed
await ApiHelper.clearCache();
await ApiHelper.clearCacheForUrl('/posts');
```

### 🔐 Authentication & Token Management

```dart
ApiHelper.configure(
  ApiConfig(
    baseUrl: 'https://api.yourapp.com',
    // 🔑 Automatic token injection
    getToken: () async => await TokenStorage.getToken(),
    // 🔄 Automatic token refresh
    onTokenExpired: () async => await AuthService.refreshToken(),
  ),
);
```

### 📁 File Operations with Progress

```dart
// 📤 Upload with real-time progress
final file = File('/path/to/image.jpg');
final response = await ApiHelper.uploadFile(
  '/upload',
  file,
  fieldName: 'image',
  fields: {'description': 'Profile picture'},
  onProgress: (sent, total) {
    final percentage = (sent / total * 100).round();
    print('Upload Progress: $percentage%');
  },
);

// 📥 Download with progress tracking
await ApiHelper.downloadFile(
  '/files/document.pdf',
  '/local/path/document.pdf',
  onProgress: (received, total) {
    final percentage = (received / total * 100).round();
    print('Download Progress: $percentage%');
  },
);
```

### 🛡️ Advanced Error Handling

```dart
try {
  final data = await ApiHelper.get('/api/data');
  // Handle success
} catch (e) {
  if (e is ApiError) {
    switch (e.type) {
      case ApiErrorType.network:
        showSnackBar('Check your internet connection');
        break;
      case ApiErrorType.server:
        showSnackBar('Server is temporarily unavailable');
        break;
      case ApiErrorType.timeout:
        showSnackBar('Request timed out. Please try again');
        break;
      case ApiErrorType.authentication:
        redirectToLogin();
        break;
      default:
        showSnackBar('Something went wrong: ${e.message}');
    }
  }
}
```

### 🔄 Smart Retry with Exponential Backoff

```dart
final data = await ApiHelper.get(
  '/unstable-endpoint',
  retry: RetryConfig(
    maxRetries: 5,
    retryDelay: Duration(seconds: 2),
    useExponentialBackoff: true, // 2s, 4s, 8s, 16s, 32s
    maxRetryDelay: Duration(seconds: 30),
  ),
);
```

### 🔧 Custom Interceptors

```dart
class AuthInterceptor extends ApiInterceptor {
  @override
  Future<void> onRequest(String method, String url, 
      Map<String, String>? headers, dynamic data) async {
    headers?['Authorization'] = 'Bearer ${await getToken()}';
    headers?['User-Agent'] = 'MyApp/1.0';
  }

  @override
  Future<void> onResponse(http.Response response) async {
    if (response.statusCode == 401) {
      await refreshToken();
    }
    // Log analytics
    Analytics.trackApiCall(response.request?.url.toString());
  }
}

// Add the interceptor
ApiHelper.instance.addInterceptor(AuthInterceptor());
```

---

## ⚙️ Configuration

### 📋 ApiConfig Options

```dart
ApiConfig(
  baseUrl: 'https://api.example.com',           // 🌐 Base URL for all requests
  defaultHeaders: {'Accept': 'application/json'}, // 📋 Default headers
  timeout: Duration(seconds: 30),               // ⏱️ Request timeout
  enableLogging: true,                          // 📝 Enable request/response logging
  getToken: () async => 'your-token',          // 🔑 Token getter function
  onTokenExpired: () async => refreshToken(),   // 🔄 Token refresh callback
  onError: (error) => handleError(error),      // 🚨 Global error handler
  retryConfig: RetryConfig(...),               // 🔄 Default retry configuration
  cacheConfig: CacheConfig(...),               // 💾 Default cache configuration
)
```

### 💾 Cache Configuration

```dart
CacheConfig(
  duration: Duration(minutes: 5),     // ⏰ How long to cache responses
  keyPrefix: 'myapp_',               // 🏷️ Prefix for cache keys
  useMemoryCache: true,              // 🧠 Enable in-memory cache
  useDiskCache: true,                // 💽 Enable persistent disk cache
  maxCacheSize: 10 * 1024 * 1024,   // 📏 Maximum cache size (10MB)
)
```

### 🔄 Retry Configuration

```dart
RetryConfig(
  maxRetries: 3,                              // 🔢 Maximum retry attempts
  retryDelay: Duration(seconds: 1),           // ⏱️ Initial delay between retries
  useExponentialBackoff: true,                // 📈 Use exponential backoff strategy
  maxRetryDelay: Duration(seconds: 30),       // ⏰ Maximum delay between retries
  retryStatusCodes: [408, 429, 500, 502, 503, 504], // 📋 HTTP status codes to retry
)
```

---

## 🚨 Error Types

The package provides detailed error classification:

| Error Type | Description | Common Causes |
|------------|-------------|---------------|
| `ApiErrorType.network` | Network connectivity issues | No internet, DNS issues |
| `ApiErrorType.timeout` | Request timeout errors | Slow connection, server overload |
| `ApiErrorType.server` | Server errors (5xx status codes) | Internal server error, maintenance |
| `ApiErrorType.client` | Client errors (4xx status codes) | Bad request, unauthorized |
| `ApiErrorType.authentication` | Authentication/authorization errors | Invalid token, expired session |
| `ApiErrorType.parsing` | JSON parsing errors | Malformed response, unexpected format |
| `ApiErrorType.unknown` | Unclassified errors | Unexpected exceptions |

---

## 🧪 Testing

The package is designed to be testable. You can easily mock API responses:

```dart
void main() {
  group('API Tests', () {
    test('should fetch users successfully', () async {
      // Mock your API calls here
      final users = await ApiHelper.get<List<User>>('/users');
      expect(users, isA<List<User>>());
      expect(users.isNotEmpty, true);
    });
    
    test('should handle network errors gracefully', () async {
      expect(
        () => ApiHelper.get('/invalid-endpoint'),
        throwsA(isA<ApiError>()),
      );
    });
  });
}
```

---

## 📱 Platform Support

<div align="center">

| Platform | Status | Notes |
|----------|--------|-------|
| **Android** | ✅ | Full support |
| **iOS** | ✅ | Full support |
| **Web** | ✅ | Full support |
| **macOS** | ✅ | Full support |
| **Windows** | ✅ | Full support |
| **Linux** | ✅ | Full support |

</div>

## 📋 Requirements

- **Flutter**: `>=3.0.0`
- **Dart**: `>=2.17.0`

---

## 📚 Examples

For complete examples, check out the **[example folder](https://pub.dev/packages/flutter_api_helper/example)** which includes:

- 🌐 Basic API operations
- 🔐 Authentication flow
- 📁 File upload/download
- 💾 Caching strategies
- 🛡️ Error handling patterns
- 🎯 Widget integration examples

---

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](https://github.com/ranahammad7/flutter_api_helper/blob/main/CONTRIBUTING.md) for details.

### 🛠️ Development Setup

1. 🍴 Fork the repository
2. 🌿 Create your feature branch (`git checkout -b feature/amazing-feature`)
3. 💾 Commit your changes (`git commit -m 'Add amazing feature'`)
4. 📤 Push to the branch (`git push origin feature/amazing-feature`)
5. 🔄 Open a Pull Request

---

## 📝 Changelog

See [CHANGELOG.md](https://pub.dev/packages/flutter_api_helper/changelog) for a detailed history of changes.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/ranahammad7/flutter_api_helper/blob/main/LICENSE) file for details.

---

## 📞 Support & Community

<div align="center">

[![📖 Documentation](https://img.shields.io/badge/📖-Documentation-blue?style=for-the-badge)](https://pub.dev/documentation/flutter_api_helper/latest/)
[![🐛 Issues](https://img.shields.io/badge/🐛-Issues-red?style=for-the-badge)](https://github.com/ranahammad7/flutter_api_helper/issues)
[![💬 Discussions](https://img.shields.io/badge/💬-Discussions-green?style=for-the-badge)](https://github.com/ranahammad7/flutter_api_helper/discussions)
[![⭐ GitHub](https://img.shields.io/badge/⭐-Star%20on%20GitHub-yellow?style=for-the-badge)](https://github.com/ranahammad7/flutter_api_helper)

</div>

---

<div align="center">
  <h3>🎉 Made with ❤️ for the Flutter community</h3>
  <p><em>If this package helped you, please consider giving it a ⭐ on GitHub!</em></p>
</div>