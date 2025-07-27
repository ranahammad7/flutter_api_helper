markdown# Flutter API Helper - Example App

This example app demonstrates all the features of the Flutter API Helper package.

## Features Demonstrated

- ✅ **Basic HTTP Operations** - GET, POST, PUT, DELETE
- ✅ **Caching** - Memory and disk caching with TTL
- ✅ **File Upload/Download** - With progress tracking
- ✅ **Error Handling** - Different error types and recovery
- ✅ **Authentication** - Token management and refresh
- ✅ **Interceptors** - Custom request/response processing
- ✅ **Widget Integration** - ApiBuilder widget usage
- ✅ **Testing** - Unit and integration tests

## Getting Started

1. **Clone and install dependencies:**
   ```bash
   cd example
   flutter pub get

Run the app:
bashflutter run

Run tests:
bashflutter test
flutter test integration_test/


Screens Overview
Home Screen
Main navigation with cards for each demo feature.
Users Screen

Demonstrates CRUD operations
Shows ApiBuilder widget usage
Error handling and retry logic

Posts Screen

Caching demonstration
Toggle between cached and fresh data
Cache management utilities

Upload Screen

File picker integration
Upload progress tracking
Error handling for file operations

Cache Demo Screen

Manual cache operations
Cache timing demonstration
Clear cache functionality

Error Demo Screen

Different error scenarios
Error type classification
Recovery strategies

Project Structure
The example is organized into logical folders:

models/ - Data classes with JSON serialization
screens/ - UI screens demonstrating different features
services/ - Business logic and API service layers
interceptors/ - Custom request/response interceptors
widgets/ - Reusable UI components

Key Learning Points
1. API Configuration
dartApiHelper.configure(
  ApiConfig(
    baseUrl: 'https://jsonplaceholder.typicode.com',
    enableLogging: true,
    timeout: Duration(seconds: 30),
    // ... other configurations
  ),
);
2. Using ApiBuilder Widget
dartApiBuilder<List<dynamic>>(
  future: ApiHelper.get('/users'),
  builder: (users) => ListView.builder(...),
  loading: CircularProgressIndicator(),
  error: (error) => Text('Error: ${error.message}'),
)
3. Custom Interceptors
dartclass AuthInterceptor extends ApiInterceptor {
  @override
  Future<void> onRequest(...) async {
    // Add auth headers
  }
  
  @override
  Future<void> onResponse(...) async {
    // Handle token refresh
  }
}
4. Error Handling
darttry {
  final data = await ApiHelper.get('/api/data');
} catch (e) {
  if (e is ApiError) {
    switch (e.type) {
      case ApiErrorType.network:
        // Handle network error
        break;
      // ... other error types
    }
  }
}
Running Different Scenarios
Test Network Errors

Turn off internet connection
Navigate to any screen that loads data
Observe error handling and retry mechanisms

Test Caching

Go to Posts screen
Load data with cache enabled
Check timestamps to see cached vs fresh data
Use cache management buttons

Test File Upload

Go to Upload screen
Pick a file from device
Watch progress indicator during upload
Handle upload errors

API Endpoints Used
This example uses JSONPlaceholder (https://jsonplaceholder.typicode.com) which provides:

/users - User CRUD operations
/posts - Post data with caching demos
/comments - Comment data
Mock upload endpoint for file demos

Customization
To adapt this example for your own API:

Update base URL in main.dart
Modify models to match your data structure
Update endpoints in service classes
Customize authentication logic if needed

