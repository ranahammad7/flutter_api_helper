import 'package:flutter/material.dart';
import 'package:flutter_api_helper/flutter_api_helper.dart';
import 'screens/home_screen.dart';
import 'services/auth_service.dart';
import 'services/token_storage.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart' as logging_interceptor;

void main() {
  // Configure API Helper globally
  ApiHelper.configure(
    ApiConfig(
      baseUrl: 'https://jsonplaceholder.typicode.com',
      enableLogging: true,
      timeout: Duration(seconds: 30),
      defaultHeaders: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      getToken: () async {
        return await TokenStorage.getToken();
      },
      onTokenExpired: () async {
        await AuthService.refreshToken();
      },
      retryConfig: RetryConfig(
        maxRetries: 3,
        retryDelay: Duration(seconds: 1),
        useExponentialBackoff: true,
      ),
      cacheConfig: CacheConfig(
        duration: Duration(minutes: 5),
        useMemoryCache: true,
        useDiskCache: true,
      ),
    ),
  );

  // Add custom interceptors
  ApiHelper.instance.addInterceptor(AuthInterceptor());
  ApiHelper.instance.addInterceptor(LoggingInterceptor());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter API Helper Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
